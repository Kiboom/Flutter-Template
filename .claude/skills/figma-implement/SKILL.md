---
name: figma-implement
description: "Figma 디자인을 Flutter 코드로 구현하는 UI 개발 스킬"
context: inherit
model: opus
allowed-tools: Read, Glob, Grep, Bash, Agent, mcp__figma__get_design_context, mcp__figma__get_screenshot, mcp__figma__get_metadata
argument-hint: "<figma-urls...> [target-file-path]"
---

# Figma → Flutter Implementation Skill

You are a pixel-perfect Flutter UI developer.
Given Figma URL(s) and optionally a target screen/widget path, you implement the design in Flutter code following this template's conventions exactly.

All responses must be in Korean (한글).

---

## Input

`$ARGUMENTS` contains a free-form string. Parse it as follows:

1. **Figma URLs** — Extract all URLs containing `figma.com`. There may be one or more.
2. **Target file path** — Extract any path containing `lib/` (optional). If absent, create a new screen following this template's pattern: `lib/screen/{이름}/{이름}_screen.dart`.

**Figma URL parsing:**

- `figma.com/design/:fileKey/:fileName?node-id=:nodeId` → convert `-` to `:` in nodeId
- `figma.com/design/:fileKey/branch/:branchKey/:fileName` → use branchKey as fileKey

---

## Workflow

### Step 0 — Load Guidelines (MANDATORY)

다른 작업을 하기 전에 이 템플릿의 규칙 파일을 먼저 `Read` 한다:

```text
Read .claude/skills/flutter-guidelines/SKILL.md
Read CLAUDE.md
```

이 두 파일이 모든 코딩 컨벤션의 **단일 기준(single source of truth)**이다.

**특히 주의할 규칙** (요약 — 전체는 flutter-guidelines 참고):

- 탭 가능한 요소에는 `GestureDetector` 대신 `lib/screen/common/spring_button.dart`의 `SpringButton` 사용
- `children` 리스트에는 `.map().toList()` 대신 `for` 루프
- 색은 raw hex 대신 `lib/core/theme.dart`의 `AppColors` 토큰 사용
- 화면은 순수 `StatefulWidget` + `setState` (상태 없으면 `StatelessWidget`). 별도 상태관리 패키지 금지
- 인자 2개 이상 함수/생성자 호출 끝에 trailing comma
- spread-if 패턴: `children`의 `if`/`for`는 반드시 `...[` 와 함께

### Step 1 — Fetch Design

For each Figma URL found in the input:

1. Call `mcp__figma__get_design_context` with the parsed `fileKey` and `nodeId`.
2. Call `mcp__figma__get_screenshot` for visual reference.
3. If the node structure is unclear, call `mcp__figma__get_metadata`.

When multiple URLs are provided, fetch them **in parallel** where possible.

4. **Write down all important visual details immediately** (colors, fonts, spacing, layout, border radius, shadows) — tool results may be cleared later.

### Step 2 — Analyze & Map Tokens

Figma 디자인의 모든 시각 속성을 이 템플릿의 디자인 토큰에 매핑한다.

1. `lib/core/theme.dart`를 `Read` 해서 현재 `AppColors` 색상 정의를 확인한다.
2. 매핑: Figma 색상 hex → `AppColors`의 가장 가까운 토큰. 간격·border radius는 Figma의 정확한 픽셀 값을 쓴다.
3. 디자인에 딱 맞는 색이 `AppColors`에 없으면, **명시적으로 보고**하고 `theme.dart`의 `AppColors`에 새 상수를 추가한 뒤 그 토큰을 쓴다 (화면 코드에 raw hex를 흩뿌리지 않는다).

**IMPORTANT:** 항상 실제 소스 파일을 `Read` 한다. 하드코딩된 표에 의존하지 말 것 — 토큰은 시간이 지나며 바뀐다.

### Step 3 — Explore Existing Widgets

코드를 쓰기 전에:

1. `lib/screen/common/` 을 `ls` 해서 재사용 가능한 공통 위젯을 확인한다 (현재 `SpringButton`, `AppHaptic` 등).
2. 대상 화면 폴더의 `widgets/` 안에 재사용·확장 가능한 위젯이 있는지 찾는다.
3. 쓰려는 위젯의 소스를 `Read` 해서 정확한 API를 파악한다.
4. 필요한 에셋(아이콘/이미지)이 프로젝트에 없으면, Figma에서 export 해 `assets/` 에 넣고 `pubspec.yaml`의 `flutter.assets`에 경로를 등록한다.

### Step 4 — Implement

Step 0의 모든 규칙을 지키며 Flutter 코드를 작성한다.

**Navigation:**
`lib/core/routes.dart`의 go_router를 쓴다. 새 경로가 필요하면 `RoutePath` enum과 `AppRoutes.config`에 추가하고, 화면 이동은 `context.push("/경로")`. (탭/겹침 구분은 new-page 스킬 참고.)

**Strings:**
이 템플릿은 별도 다국어(localization) 시스템을 쓰지 않는다. 사용자에게 보이는 문자열은 한국어로 직접 적어도 된다.

**Assets:**
`pubspec.yaml`에 등록한 경로로 `Image.asset("assets/...")` 처럼 직접 참조한다 (FlutterGen 같은 코드 생성은 쓰지 않는다).

**Screen boilerplate:**
`CLAUDE.md`와 기존 화면(`lib/screen/page1/page1_screen.dart`)의 패턴을 따른다. 비동기 데이터가 있으면 로딩/에러/데이터 3상태를 `setState`로 다룬다.

### Step 5 — Triple Review (MANDATORY — DO NOT SKIP)

**이 단계는 선택이 아니다. 끝내기 전에 반드시 3개 리뷰 에이전트를 모두 실행한다.**

Agent 도구로 3개의 리뷰 서브 에이전트를 **병렬로** 띄운다:

**Agent 1 — Pixel Accuracy & Token Review:**
Prompt: "아래 파일들을 읽고 Figma 디자인과 정확히 일치하는지 리뷰하세요. (1) 색상 hex 값, 간격(px), 타이포그래피(font size, weight, line height), 그림자, border radius를 하나씩 대조 검증하세요. (2) `lib/core/theme.dart`의 `AppColors`를 읽고 색상 토큰 매핑이 정확한지, raw hex 값 대신 토큰을 쓰는지 확인하세요. 불일치 항목을 리스트로 보고하세요. 파일: [구현한 파일 경로들]"

**Agent 2 — Code Quality & Widget Reuse Review:**
Prompt: "시니어 Flutter 엔지니어 관점에서 아래 파일들의 코드 품질을 리뷰하세요. 반드시 `.claude/skills/flutter-guidelines/SKILL.md` 를 읽고 준수 여부를 확인하세요. 특히: (1) trailing commas 누락(2+ args), (2) 탭 요소에 GestureDetector 사용(SpringButton 써야 함), (3) `.map().toList()` 사용(children에는 for 루프), (4) 색을 raw hex로 직접 사용(AppColors 토큰 써야 함), (5) 큰따옴표·`package:` import 위반, (6) 불필요한 rebuild(const 누락), (7) 공통 위젯 재사용 기회 누락, (8) spread-if 패턴 위반(if/for 뒤에 반드시 ...[]), (9) 별도 상태관리 패키지 사용(순수 StatefulWidget+setState여야 함). 파일: [구현한 파일 경로들]"

**Agent 3 — Edge Case Review:**
Prompt: "아래 파일들을 읽고 다양한 화면 크기(small phone, tablet), 긴 텍스트 오버플로우, 빈 상태, 로딩/에러 상태 등 엣지 케이스를 검토하세요. 각 케이스에서 발생할 수 있는 문제를 보고하세요. 파일: [구현한 파일 경로들]"

3개 에이전트가 모두 끝나면 **보고된 모든 이슈를 고치고**, 무엇을 고쳤는지 요약한다.
