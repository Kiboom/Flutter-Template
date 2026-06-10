---
name: new-page
description: "Flutter 프로젝트에 새 페이지를 추가한다. 라우트 등록 + 페이지 위젯 파일 생성 + 로딩/에러/데이터 3상태 골격 + 호출부 1줄 안내까지 한 번에. 사용자가 '새 페이지 만들어줘', '~~ 화면 추가', 'add a new screen/page', '/new-page' 라고 말하면 호출."
---

# new-page — Flutter 페이지 추가 스킬

새 화면 하나를 추가하는 작업의 **반복 부분만** 자동화한다. 디자인 결정, 상태/데이터 모델, API 호출 같은 **사고가 필요한 부분은 자동화하지 않는다** — 사용자(또는 학생)가 직접 채우도록 명확한 자리(placeholder)와 주석을 남긴다.

## 호출 인자

`$ARGUMENTS` 자유 텍스트로 다음을 추출한다:

- **페이지 이름** (필수). 예: `Search`, `StockDetail`, `Profile`. PascalCase로 정규화.
- **경로 이름** (선택). 예: `/search`, `/stock/:code`. 없으면 페이지 이름을 snake_case로 변환해 사용.
- **요약 한 줄** (선택). 페이지가 하는 일.

추출이 모호하면 진행 전에 사용자에게 한 문장으로 확인.

## 워크플로우

### Step 1 — 패턴 확인

이 템플릿의 기본 패턴은 정해져 있다:

- **라우팅**: go_router. 경로는 `lib/core/routes.dart`의 `RoutePath` enum + `AppRoutes.config`.
- **화면 위치**: `lib/screen/{이름}/{이름}_screen.dart`. 세부 위젯은 같은 폴더의 `widgets/`.
- **상태관리**: 순수 StatefulWidget + `setState` (상태 없으면 StatelessWidget).
- **명명**: `Screen` 접미사, `_screen.dart` 파일.

작업 전 기존 화면 한두 개(`page1_screen.dart` 등)를 읽어 패턴을 확인하고, 한 줄로 보고한 뒤 진행한다. 누군가 이 템플릿을 다른 구조로 바꿨다면 **가정하지 말고** 그 화면의 실제 패턴을 그대로 따른다.

### Step 2 — 페이지 파일 생성

탐지된 위치에 새 페이지 파일 1개를 만든다. 본문은 다음 골격을 따른다 (탐지된 상태관리·명명 규칙에 맞춰 변형):

```dart
import "package:flutter/material.dart";

class XxxScreen extends StatefulWidget {
  const XxxScreen({super.key});

  @override
  State<XxxScreen> createState() => _XxxScreenState();
}

class _XxxScreenState extends State<XxxScreen> {
  bool _isLoading = true;
  Object? _error;
  // TODO: 데이터 필드를 여기 채워주세요.

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // TODO: 실제 데이터 호출(레포지토리)로 교체해주세요.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Xxx")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("문제가 생겼어요"),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _load, child: const Text("다시 시도")),
          ],
        ),
      );
    }
    // TODO: 본문을 채워주세요.
    return const Center(child: Text("Xxx screen"));
  }
}
```

규칙:

- `Xxx`를 실제 화면 이름으로 치환. 이 템플릿은 `Screen` 접미사 + `{이름}_screen.dart` + 큰따옴표를 쓴다.
- 상태가 없는 화면이면 `StatelessWidget`으로 단순화한다 (예: 정적 화면).
- 데이터 모델·API 호출은 TODO 주석으로 남기고 **임의로 만들지 않는다**. 통신이 필요하면 `lib/data/`에 레포지토리를 두고 거친다.
- 항상 `flutter-guidelines` 규칙을 적용한다 (trailing commas, 큰따옴표, `package:` import 등).

### Step 3 — 라우트 등록

이 템플릿은 `lib/core/routes.dart` 한 곳에서 라우트를 관리한다. 두 단계로 등록한다:

1. `RoutePath` enum에 경로를 추가한다. 예: `search("/search")`. 경로 파라미터가 필요하면 `detail("/detail/:id")`.
2. 화면 종류에 따라 등록 위치를 고른다:
   - **탭 위에 겹쳐 띄우는 화면**(상세, 폼 등, 대부분 여기): `branches` **밖**의 최상위 `GoRoute` 리스트에 추가한다.
   - **새 하단 탭**: `StatefulShellRoute`의 `branches`에 `StatefulShellBranch`를 추가하고, `navigation_screen.dart`의 `destinations`도 같은 순서로 함께 늘린다.

경로 파라미터는 `state.pathParameters["id"]`로 꺼내 화면 생성자에 넘긴다 (`Page2Screen` 참고).

### Step 4 — 호출부 안내

마지막에 사용자에게 한 줄로 호출 예시를 알려준다. 호출부 코드를 **자동 삽입하지 않는다** (어디서 부를지는 사용자 결정). 예:

> 호출 예시: `context.push("/search")` (현재 화면 위에 띄우고 뒤로가기로 닫기)

### Step 5 — 최종 보고

다음 3가지만 한 줄씩 보고:

1. 만든 파일 경로 (markdown link)
2. 등록한 라우트 (있다면)
3. 다음 할 일 TODO 목록 (데이터 모델, API 호출 등)

## 하지 말 것

- **데이터 모델·API 응답 구조 추측해서 만들지 말 것**. TODO로 두고 사용자에게 묻거나 채우게 한다.
- **상태관리 패턴을 강제로 바꾸지 말 것**. 기존 프로젝트가 setState만 쓰면 새 페이지에 Riverpod을 끼워 넣지 않는다.
- **이미 만들어진 페이지의 코드를 수정하지 말 것** — 새 페이지 1개 추가가 책임 범위다.
- **테스트 파일 자동 생성 금지** — 별도 요청 시에만.
- 디자인·아이콘·색상 결정 금지. AppBar 제목·기본 본문 텍스트 정도만 둔다.

## 톤

응답은 한국어. 한 페이지 추가는 짧은 작업이므로 보고도 짧게.
