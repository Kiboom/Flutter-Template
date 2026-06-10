# 프로젝트 규칙 (AI 에이전트용)

이 파일은 이 프로젝트에서 작업하는 모든 AI 코딩 도구(Claude Code, OpenAI Codex, Cursor 등)가 따르는 **단일 정본 규칙**이다.
도구별 설정(`CLAUDE.md`, `.cursor/rules/`)은 이 파일을 가리키므로, 규칙을 바꿀 때는 **여기 한 곳만** 고치면 된다.

## 코딩 가이드라인

Dart/Flutter 코드를 작성·수정할 때는 항상 `.claude/skills/flutter-guidelines/SKILL.md`의 규칙을 적용한다.
핵심: 큰따옴표(`"`) 사용, `package:` 절대 경로 import, 인자 2개 이상이면 trailing comma, 타입·반환타입 명시.

## 프로젝트 구조

```
lib/
  main.dart            앱 진입점
  core/                공통 기반 (앱 실행, 라우팅, 테마, 로거)
  data/                모델 + 레포지토리 (네트워크 통신)
  screen/              화면 단위 폴더 (screen + widgets)
    common/            여러 화면이 공유하는 위젯
    navigation/        하단 탭바 (StatefulShellRoute)
```

- 하단 탭바는 `StatefulShellRoute.indexedStack`으로 구성한다. 탭 화면은 `branches`, 탭 위에 겹쳐 띄우는 화면(상세 등)은 branch 밖의 일반 `GoRoute`에 둔다.
- 탭을 추가할 때는 `navigation_screen.dart`의 `destinations`와 `routes.dart`의 `branches`를 같은 순서·개수로 맞춰 함께 수정한다.
- 화면은 `screen/{이름}/{이름}_screen.dart`. 세부 위젯은 같은 폴더의 `widgets/`에 둔다.
- 상태 관리는 순수 `StatefulWidget` + `setState`. 별도 상태관리 패키지를 끼워 넣지 않는다.
- 모델은 `freezed`/`json_serializable` 없이 손으로 `fromJson`/`toJson`을 쓴다.
- 네트워크는 화면에서 직접 호출하지 말고 `data/`의 레포지토리를 거친다.

## 새 화면 추가

라우트 등록은 `lib/core/routes.dart`의 `RoutePath` enum과 `AppRoutes.config`에 추가한다.
탭 위에 겹쳐 띄우는 화면은 최상위 `GoRoute`, 새 하단 탭은 `StatefulShellBranch`로 추가한다.
자세한 절차는 `new-page` 스킬(아래 참고).

## iOS

SwiftPM을 끄고 CocoaPods를 쓴다 (`pubspec.yaml`의 `flutter.config.enable-swift-package-manager: false`). 이 설정을 되돌리지 않는다.

## 앱 이름 변경

`python3 scripts/rename_app.py <새이름>`으로 패키지 이름·번들 ID·표시 이름을 한 번에 바꾼다.

## 스킬 (작업 플레이북)

`.claude/skills/` 에 작업별 상세 플레이북이 있다. 해당하는 작업을 할 때는 **먼저 그 스킬의 `SKILL.md`를 읽고 따른다.**
(Claude Code는 `/이름`으로 바로 실행할 수 있고, Codex·Cursor는 파일을 직접 읽어 동일하게 활용한다.)

| 스킬 | 언제 읽나 | 경로 |
|------|----------|------|
| `flutter-guidelines` | 모든 Dart/Flutter 코드 작성 시 (항상) | `.claude/skills/flutter-guidelines/SKILL.md` |
| `new-page` | 새 화면/페이지를 추가할 때 | `.claude/skills/new-page/SKILL.md` |
| `figma-implement` | Figma 디자인을 코드로 구현할 때 | `.claude/skills/figma-implement/SKILL.md` |
| `multi-review` | 코드를 여러 관점으로 리뷰할 때 | `.claude/skills/multi-review/SKILL.md` |
| `troubleshoot` | 버그·에러를 진단·해결할 때 | `.claude/skills/troubleshoot/SKILL.md` |

## 응답 언어

사용자에게 보여주는 응답은 한국어로 작성한다.
