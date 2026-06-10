---
name: flutter-guidelines
description: "Dart & Flutter 코딩 가이드라인 — 이 템플릿 프로젝트에 적용"
---

# Dart & Flutter Coding Guidelines

이 템플릿(`core` / `data` / `screen` 구조, 순수 StatefulWidget, go_router, http, 바닐라 모델)에 맞춘 코딩 규칙.

## Dart General

### Basics

- Declare types for all variables, parameters, and return values.
- 식별자(클래스·변수·함수명)는 영어로 짓는다. 주석은 학습용 한국어 설명을 허용하되, 식별자·타입만 봐도 아는 내용은 반복하지 않는다.
- Do not leave blank lines inside functions.
- Use `"` for strings and imports.
- Use absolute import paths (`package:` imports).
- `dynamic`을 피한다. 단 JSON 파싱처럼 불가피한 경우는 받은 즉시 구체 타입으로 캐스팅한다 (예: `json["id"] as int`).
- **Always add trailing commas** after the last argument in function/constructor calls **with 2 or more arguments**. Single-argument calls do NOT need trailing commas. This is critical — `require_trailing_commas` lint is disabled in Dart 3.7+ and the formatter uses `preserve` mode, so trailing commas must be added manually without exception.

### Naming

- **Classes**: PascalCase
- **Variables/Functions/Methods**: camelCase
- **Files/Directories**: snake_case
- **Constants**: UPPERCASE for environment variables
- **Booleans**: Prefix with verbs (isLoading, hasError, canDelete)
- **Functions**: Start with a verb (getUser, saveBook, fetchPosts)
- Avoid abbreviations; use full words with correct spelling.
  - Exceptions: standard abbreviations (API, URL), loop variables (i, j)
- Avoid magic numbers; define constants.

### Functions

- Write short functions with a single purpose (under 20 statements).
- Naming: `isX`/`hasX`/`canX` for booleans, `executeX`/`saveX` for void.
- Avoid block nesting: use early returns, extract utility functions.
- Use arrow syntax for simple functions (under 3 statements).
- Use default parameter values instead of null checks.

### Classes

- Follow SOLID principles.
- Prefer composition over inheritance.
- Write small, single-purpose classes.

### Exceptions

- Use exceptions for unexpected errors.
- Only catch exceptions to: fix expected issues, add context, or delegate to a global handler.

## Flutter

### Widget & UI

- Split large widgets into `_build{WidgetName}()` methods.
- `_build` 메서드 안에서는 State의 필드에 직접 접근한다. 매개변수로 넘기지 않는다.
- 작고 비공개인 조각은 부모의 `_build...` 메서드로 둔다. 한 화면 안에서 반복되거나 독립적으로 의미가 있는 세부 위젯은 `widgets/` 폴더의 별도 파일(클래스)로 분리한다 (예: `PostTile`).
- Use `EdgeInsets.only` / `symmetric` / `all` instead of `EdgeInsets.fromLTRB`.
- Use `withValues(alpha: x)` instead of deprecated `withOpacity(x)`.
- Use `for` loops inside widget `children` lists instead of `List.generate()` or `map()`. This rule applies only to widget lists (e.g., `children`, `Column`, `Row`). For non-widget data collections, `.where()`, `.map()`, `.toList()` etc. are fine.
- Nullable access: prefer `?.` even when value is known to be non-null.
- Spread-if pattern: `if`/`else if`/`else`/`for` in `children` lists MUST always be followed by `...[`. Never use `if`/`for` standalone without `...[`, and never use `...[` standalone without `if`/`for` before it.

```dart
Column(
  children: [
    Text("Header"),
    if (condition) ...[
      Text("Conditional"),
    ],
    if (flag) ...[
      Text("A"),
    ] else ...[
      Text("B"),
    ],
    for (final item in items) ...[
      ItemWidget(item: item),
    ],
  ],
)
```

- Use `async/await` + `try-catch` instead of `.then()`.
- Enum-based comparison instead of string comparison where possible.

### Performance

- Avoid deeply nested widget trees; decompose into smaller, reusable components.
- Use `const` constructors wherever possible to reduce rebuilds.
- Keep widget tree shallow for better rendering.

### State Management (순수 StatefulWidget)

이 템플릿은 별도 상태관리 패키지(Riverpod / BLoC / Provider)를 쓰지 않는다. 새 화면에도 끼워 넣지 않는다.

- 화면은 상태가 있으면 `StatefulWidget`, 없으면 `StatelessWidget`.
- 상태는 `setState`로 관리한다.
- 네트워크 같은 비동기 데이터는 로딩 / 에러 / 데이터 3상태를 필드(`_isLoading`, `_error`, 데이터)로 들고, `initState`에서 로드한 뒤 `setState`로 갱신한다. (`lib/screen/page1/page1_screen.dart` 참고)
- 비동기 작업 후 `setState` 직전에는 항상 `if (!mounted) return;`로 가드한다.
- 데이터 통신은 화면에서 직접 하지 말고 `lib/data/`의 레포지토리를 거친다.

### Screen Organization

```text
lib/screen/{screen_name}/
├── {screen_name}_screen.dart   # 화면 (StatefulWidget 또는 StatelessWidget)
└── widgets/                    # 이 화면 전용 세부 위젯
```

- 화면별 `_controller.dart` / `_state.dart` 파일을 따로 두지 않는다. 상태는 `_{Screen}State` 안에서 관리한다.
- 여러 화면이 공유하는 위젯은 `lib/screen/common/`에 둔다.
- 모델과 네트워크 통신은 `lib/data/{도메인}/`(모델 + 레포지토리), 앱 공통 기반(앱 실행·라우팅·테마·로거)은 `lib/core/`에 둔다.
- 하단 탭바는 `lib/core/routes.dart`의 `StatefulShellRoute.indexedStack`으로 구성한다.

### Design Tokens

- 색상은 `lib/core/theme.dart`의 `AppColors`에 상수로 모은다. 텍스트 스타일·박스 스타일도 한 곳에 모은다.
- 텍스트 스타일 확장은 `copyWith`로 하고, 기존 속성을 다시 정의하지 않는다.
- 에셋을 추가하면 경로 문자열을 여기저기 흩뿌리지 말고 한 곳에 모아 참조한다.

All responses should be in Korean.
