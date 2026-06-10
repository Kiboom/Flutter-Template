# Multi-Review (다중 리뷰)

여러 독립적인 관점에서 병렬 리뷰를 수행합니다. 결과는 사용자가 **빠르게 훑어보고 결정 가능한 형태**로 정리합니다.

## Parameters
- `$ARGUMENTS` — 첫 번째 숫자는 리뷰어 수 (없으면 default 3), 나머지는 리뷰 주제/대상

## Instructions

1. Parse $ARGUMENTS:
   - 첫 번째 토큰이 숫자면 리뷰어 수 (N), 아니면 N=3
   - 나머지 전체를 리뷰 주제(focus topic)로 사용
   - 리뷰 대상은 주제에서 파악하거나, 직전 대화 컨텍스트에서 자연스럽게 추론

2. Launch N Agent tools **in parallel**, each with a distinct reviewer persona.

   기본 3명 구성:
   - Reviewer 1: **정확성 (Accuracy)** — 사실 관계, 기술적 정확성, 논리적 오류, 검증 가능한 주장 확인
   - Reviewer 2: **완전성 (Completeness)** — 누락된 정보, 빠진 엣지 케이스, 추가 필요 항목
   - Reviewer 3: **명확성 & 규칙 준수 (Clarity & Compliance)** — 구조, 가독성, 톤, 대상 독자 적합성. Flutter/Dart 코드인 경우 프로젝트의 SKILL.md 및 flutter-guidelines 규칙 준수 여부도 검토

   4명 이상이면 주제에 맞게 추가 관점 할당 (e.g. 보안, 성능, UX, 비용, 리스크 등)

3. Each reviewer agent must produce, **per issue**:
   - 구체적 위치(파일/라인/섹션) 참조
   - 심각도: HIGH / MEDIUM / LOW
   - **confidence (0~100)**: 이 이슈가 실제 문제일 자신감
   - **영향도 (0~100)**: 발생 시 사용자/시스템에 미치는 임팩트
   - 한 줄 요지 + 구체적 수정 방안 (단순 수정은 diff 스니펫 첨부)
   - 간결하게 — 불필요한 반복이나 서론 없이

4. After all agents complete, synthesize:
   - **출력은 plan 파일로**. 현재 conversation 의 plan 파일이 시스템 메시지 (`A plan file exists at ~/.claude/plans/{name}.md`) 로 안내되어 있다면 그 파일에 작성하고 마지막에 `ExitPlanMode` 를 호출.
   - **plan 파일 경로가 안내되지 않은 경우(plan mode 가 아닌 경우)에는 먼저 `EnterPlanMode` 를 호출해 plan mode 로 진입한다.** 사용자에게 plan mode 진입 승인 prompt 가 1회 뜨고, 승인 후 시스템 메시지로 plan 파일 경로가 안내된다. 그 파일에 결과를 작성하고 마지막에 `ExitPlanMode` 호출로 마무리. 자동으로 별도 파일을 만들지 말 것 — 항상 plan 파일을 사용한다.
   - 종합 단계에서 명백한 false positive(다른 reviewer가 명시적으로 반박했거나 코드 근거상 안전한 항목)는 본문에서 제거하거나 `### 종합 단계에서 제거된 이슈` 섹션에 한 줄씩만 기록(왜 제거했는지 포함). plan에는 **결정 가치가 있는 이슈만** 남긴다.

## Plan 파일 형식 (가독성 최우선)

이슈가 많아도 사용자가 **3단계 정독**으로 끝낼 수 있게 구조화한다:
1. **결정 시트만 보고** 단순 결정은 즉답
2. **다중 합의 묶음 박스만 보고** 일괄 처리
3. **본문은 결정 흔들리는 항목만 펼쳐봄**

### 1) 헤더와 Context

```markdown
# Multi-Review: {topic}

## Context
{왜 리뷰하는지·전체 변경 범위·리뷰어 N명 구성}
```

### 2) TL;DR 결정 시트 (맨 위, 본문보다 앞)

| ID | 심각도 | 한 줄 요지 (30~60자) | 권장 액션 |
|---|---|---|---|
| H1 | 🚨 HIGH | LLM 페이지 순서 가정으로 그룹 통일 기준이 흔들릴 수 있음 | 🟢 처리 권장 |
| H2 | 🚨 HIGH | enum description으로만 강제하는 제약은 LLM이 무시할 수 있음 | 🟡 결정 필요 |
| M1 | 🛠 MED | inconsistency 로깅 부재 | 🟢 처리 권장 |
| L1 | 🔧 LOW | dead code 정리 | ⚪ FYI |

권장 액션 라벨 정의:
- 🟢 **처리 권장**: 합의·근거 명확, 수정 비용 낮음, NO만 표시하면 됨.
- 🟡 **결정 필요**: trade-off가 있어 사용자 판단 필요. 본문 정독 후 결정.
- ⚪ **FYI**: 즉시 액션 불필요. 인지만.

### 3) 다중 합의 묶음 박스 (TL;DR 바로 아래)

```markdown
## ✅ 다중 합의 묶음 (기본 처리 권장 — NO만 표시)
2명 이상 reviewer가 같은 이슈를 짚었고 수정 방안이 명확한 항목들. 
별도 결정 없이 일괄 적용해도 안전한 묶음.

- **M1** (R2 + R4): inconsistency 로깅 추가
- **M3** (R2 + R4): DB row의 옛 prompt 문구 갱신
```

단독 의견 중 영향 큰 항목은 별도 섹션 없이 본문 표에서 ⚠ 단독 태그만.

### 4) 심각도별 본문 (요지/상세 2단 구조)

표가 아닌 **카드형(헤더 + 펼쳐진 sub-bullet)**을 사용한다. 표 셀에 모든 정보를 우겨넣지 않고, 헤더에서 한 줄 요지를 보고 sub-bullet에서 상세를 본다.

```markdown
## 🚨 HIGH

### H1. {짧은 제목} — 🟢 처리 권장 / ✅ 다중 합의(R1, R4)
> **요지**: 한 줄 핵심 (30~60자, 굵게).

- **어떤 상황**: 유저나 코드 관점에서 실제로 무슨 일이 벌어지는지를 구체적 시나리오와 함께 설명한다.
- **왜 일어나는가**: 어느 호출·상태·조건이 이 증상을 만드는지 파일/라인/변수명을 인용해 짚는다.
- **얼마나 자주**: 누가, 언제, 어떤 빈도로 겪는지. 엣지 케이스나 운영상 빈도를 함께.
- **어떻게 고치나**: 어떻게 바뀌는지 한 문장 + 단순 수정이면 diff 스니펫.
  ```diff
  - const groupType = first?.illustration?.type ?? IllustrationSizeType.HALF_PAGE;
  + const sorted = pages.slice().sort((a, b) => a.pageNumber - b.pageNumber);
  + const groupType = sorted[0]?.illustration?.type ?? IllustrationSizeType.HALF_PAGE;
  ```
- **메타**: confidence 85 / 영향도 70

### H2. ...
```

각 이슈는 **헤더에 라벨·합의 태그를 모두 표시**하므로 사용자는 펼치지 않고도 헤더만 훑어 결정 가능.

### 가독성 가이드 (이슈 본문 작성 시)

본문은 사용자가 한 번 읽고 바로 이해할 수 있어야 한다. 다음 원칙으로 쓴다.

- **자연스러운 흐름이 1순위**. 무조건 단문으로 끊지 말고, 한 문장 안에 한 호흡으로 읽힐 만큼은 자연스럽게 이어 쓴다. 만연체(여러 절을 길게 늘어놓는 문장)는 피하되, 짧은 단문만 잔뜩 늘어놓아 흐름이 끊기는 것도 피한다.
- **전문 용어는 풀어쓰거나 짧은 설명을 곁들인다**. 예: "비결정적 회귀(같은 입력에서도 결과가 달라짐)", "letterbox(여백)" 처럼 첫 등장 때 한 번만 풀어주면 된다.
- **수치·근거는 구체적으로**. "가끔 발생" 대신 "추정 5~15%", "한 번이라도 발생하면 …", "한 줄 추가로 끝난다" 같이 사용자가 비용·영향을 가늠할 수 있게.
- **sub-bullet 라벨은 직관적인 한국어**. `어떤 상황 / 왜 일어나는가 / 얼마나 자주 / 어떻게 고치나`. 영어 라벨(Symptom/Cause/Impact/Fix)보다 훑기 빠르다.
- **한 항목당 4~8문장**이 적정. 너무 짧으면 결정 근거가 부족하고, 너무 길면 훑기 어려워진다.
- **한 문장 내 다중 인용·괄호 중첩 자제**. 한 문장은 가능한 한 가지 메시지만 담는다. 인용과 부연이 필요하면 다음 문장으로 분리한다.

### 5) 우선순위 제안 (마무리)

```markdown
## 우선순위 제안

### High Priority
- H1, M1 — 합의되고 비용 낮음.

### Medium Priority
- H2, M2

### Low Priority
- L1, L2
```

### 6) 종합 단계에서 제거된 이슈 (선택)

```markdown
### 종합 단계에서 제거된 이슈
- (R3) "X 함수에 주석 추가" — 다른 reviewer가 짚은 surgical change 원칙과 충돌, 우선순위 낮아 제거.
```

## 작성 규칙

- **TL;DR 시트의 "한 줄 요지"는 본문 헤더의 ">요지" 줄과 일치**시켜 일관성 유지.
- 본문 sub-bullet은 증상/원인/영향/수정/메타 5개 모두 채울 것. 빈 항목 두지 말 것.
- 수정 방안에 변수명·패턴만 던지지 말고 "어떻게 바뀌는지" 한 문장 설명 + diff(가능하면).
- LOW 항목도 같은 sub-bullet 구조 유지(축약 표 금지). 다만 본문은 짧게 1~2줄씩.
- **모든 리뷰어가 이슈 없음**이면 plan에 그 사실만 명확히 기록 + ExitPlanMode.
- 합의 태그는 헤더에 명시: `✅ 다중 합의(R1, R4)` 또는 `⚠ 단독(R2)`.
- ID 명명: H1/H2/M1/M2/L1/L2 — 사용자가 결정 코멘트할 때 짧게 참조 가능하게.

## 마무리

5. plan 파일 작성 후 `ExitPlanMode` 를 호출. 그 외 추가 텍스트나 채팅 요약은 최소한(1~2줄)으로. 사용자가 plan 검토 UI 에서 결정 코멘트를 달도록 둔다.

## Example Usage
```
/multi-review the support ticket draft above
/multi-review 5 security implications of this API change
/multi-review lib/screen/page1/page1_screen.dart 의 로딩/에러 처리
```
