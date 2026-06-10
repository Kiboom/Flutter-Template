# Flutter 앱 템플릿

플러터로 **본인만의 앱을 처음 만드는 학생**을 위한 기본 템플릿입니다.
복잡한 설정 없이, 화면을 그리고 서버와 통신하는 데 필요한 최소한의 뼈대만 담았습니다.

처음 보면 좋은 파일 순서: `lib/main.dart` → `lib/core/app_runner.dart` → `lib/screen/page1/page1_screen.dart`

---

## 시작하기

### 1. 앱 이름 바꾸기

`template`이라는 이름을 내 앱 이름으로 바꿉니다. (한 번만 하면 됩니다.)

```bash
python3 scripts/rename_app.py my_app --display "내 앱" --org com.mycompany
```

| 인자 | 설명 | 예시 |
|------|------|------|
| `my_app` | 패키지 이름. 소문자·숫자·밑줄만 | `todo_list` |
| `--display` | 홈 화면에 보이는 앱 이름 (생략 가능) | `"할 일 목록"` |
| `--org` | 번들 ID 앞부분 (생략 시 기존 값 유지) | `com.mycompany` |

### 2. 패키지 받고 실행하기

```bash
flutter clean
flutter pub get
flutter run
```

실행하면 공개 API(JSONPlaceholder)에서 게시글 목록을 받아와 보여주는 예제가 뜹니다.
목록을 탭하면 상세 화면으로 이동합니다.

---

## 프로젝트 구조

```
lib/
├── main.dart                  앱 진입점 (AppRunner.run 호출)
├── core/                      앱 전체가 공유하는 기반 코드
│   ├── app_runner.dart        앱 시작·전역 에러 처리·초기화
│   ├── app.dart               MaterialApp 설정
│   ├── routes.dart            화면 경로(라우트) 정의
│   ├── theme.dart             색상·테마
│   └── logger.dart            로그 출력 헬퍼
├── data/                      데이터 (모델 + 서버 통신)
│   ├── api_requester.dart     HTTP 통신 공통 래퍼
│   └── post/
│       ├── post.dart          게시글 모델 (fromJson / toJson)
│       └── post_repository.dart  게시글 서버 통신
└── screen/                    화면
    ├── common/                여러 화면이 함께 쓰는 위젯
    │   ├── spring_button.dart    누르면 살짝 줄어드는 버튼
    │   └── haptic_feedback.dart  진동(햅틱) 헬퍼
    ├── navigation/
    │   └── navigation_screen.dart  하단 탭바 (탭 전환 담당)
    ├── page1/                  1번 탭
    │   ├── page1_screen.dart      목록 예제 화면
    │   └── widgets/
    │       └── post_tile.dart     목록의 한 줄 위젯
    ├── page2/                  Page1에서 탭하면 겹쳐 뜨는 상세 화면
    │   └── page2_screen.dart
    └── page3/                  2번 탭
        └── page3_screen.dart
```

화면 이동은 두 종류입니다.

- **탭 전환**: 하단 탭바로 큰 화면(게시글/프로필)을 오간다. 탭마다 화면 스택이 따로 유지됩니다.
- **겹쳐 띄우기**: 목록에서 상세로 들어가듯 현재 화면 위에 새 화면을 쌓는다. `context.push("/page2/1")`로 띄우고, 뒤로가기로 닫습니다.

### 설계 원칙

- **화면(screen)**: 폴더 하나가 화면 하나. `{이름}_screen.dart`와, 필요하면 `widgets/` 폴더에 세부 위젯을 둡니다. 별도의 state/controller 파일은 두지 않습니다.
- **상태 관리**: 순수 `StatefulWidget` + `setState`만 씁니다. 로딩 / 에러 / 데이터 세 가지 상태를 다루는 패턴은 `page1_screen.dart`를 그대로 따라 하면 됩니다.
- **데이터(data)**: 모델과 서버 통신만 담당합니다. 화면은 서버 주소나 JSON을 몰라도 되고, 레포지토리의 메서드만 부르면 됩니다.

---

## 자주 하는 작업

### 새 화면 추가하기

Claude Code에서 `/new-page` 를 사용하면 라우트 등록 + 화면 파일 + 3상태 골격을 한 번에 만들어 줍니다.
직접 만들 때는:

1. `lib/screen/{이름}/{이름}_screen.dart` 생성 (`page1_screen.dart` 복사 추천)
2. `lib/core/routes.dart`의 `RoutePath` enum에 경로 추가
3. `AppRoutes.config`의 `routes`에 `GoRoute` 추가
4. 이동할 때: `context.push("/경로")` (현재 화면 위에 띄우고 뒤로가기로 닫기)

### 탭 추가하기

하단 탭을 하나 더 늘리려면 두 곳을 같이 고칩니다.

1. `lib/screen/navigation/navigation_screen.dart`의 `destinations`에 `NavigationDestination` 추가
2. `lib/core/routes.dart`의 `branches`에 `StatefulShellBranch` 추가 (위 순서와 개수를 맞출 것)

### 새 데이터(모델 + 서버 통신) 추가하기

1. `lib/data/{도메인}/{도메인}.dart`에 모델 작성 (`post.dart` 참고)
2. `lib/data/{도메인}/{도메인}_repository.dart`에 `ApiRequester`를 쓰는 통신 메서드 작성 (`post_repository.dart` 참고)
3. 서버 주소를 바꾸려면 `lib/data/api_requester.dart`의 `kBaseUrl` 수정

### 색상 추가하기

`lib/core/theme.dart`의 `AppColors`에 추가한 뒤 `AppColors.primary`처럼 씁니다.

---

## AI 코딩 도구 규칙 (Claude Code / Codex / Cursor)

이 템플릿은 어떤 AI 코딩 도구를 쓰든 같은 규칙·스킬이 적용되도록 설정되어 있습니다.

- **`AGENTS.md`** — 모든 규칙의 **단일 정본**. 규칙을 바꿀 땐 이 파일만 고치면 됩니다.
- **`CLAUDE.md`** — Claude Code용. `AGENTS.md`를 가리킵니다.
- **`CLAUDE.local.md`** — 개인·로컬 규칙을 적는 곳 (공통 규칙 위에 덧붙임).
- **`.cursor/rules/project.mdc`** — Cursor용. `AGENTS.md`를 가리킵니다.
- **Codex** — 루트의 `AGENTS.md`를 자동으로 읽습니다 (별도 설정 불필요).

### 포함된 스킬

`.claude/skills/` 안의 작업별 플레이북입니다. Claude Code에서는 `/이름`으로 바로 실행하고, Codex·Cursor에서는 해당 `SKILL.md`를 읽어 동일하게 활용합니다.

| 스킬 | 용도 |
|------|------|
| `flutter-guidelines` | Dart/Flutter 코딩 규칙 (항상 적용) |
| `new-page` | 새 화면 추가 자동화 |
| `figma-implement` | Figma 디자인을 Flutter 코드로 구현 |
| `multi-review` | 여러 관점으로 코드 리뷰 |
| `troubleshoot` | 문제 해결 워크플로우 |

모든 규칙·스킬은 이 템플릿 구조(core/data/screen, 순수 StatefulWidget, go_router)에 맞게 정리되어 있습니다.

---

## 사용 패키지

| 패키지 | 용도 |
|--------|------|
| `go_router` | 화면 이동(라우팅) |
| `http` | 서버 통신 |
| `gaimon` | iOS 햅틱(진동) 피드백 |

---

## 참고

- **iOS**: 빌드 속도 때문에 Swift Package Manager 대신 CocoaPods를 씁니다. (`pubspec.yaml`에 설정됨) 이 설정은 되돌리지 마세요.
- 요구 환경: Flutter 3.44 이상.
