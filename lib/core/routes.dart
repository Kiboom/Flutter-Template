import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:template/screen/navigation/navigation_screen.dart";
import "package:template/screen/page1/page1_screen.dart";
import "package:template/screen/page2/page2_screen.dart";
import "package:template/screen/page3/page3_screen.dart";

/// 앱의 모든 경로를 한 곳에 모아둔다. 경로 문자열을 직접 쓰지 말고
/// `RoutePath.page2.path` 처럼 enum으로 참조하면 오타를 줄일 수 있다.
enum RoutePath {
  page1("/"),
  page2("/page2/:id"),
  page3("/page3");

  const RoutePath(this.path);

  final String path;
}

class AppRoutes {
  AppRoutes._();

  /// 하단 탭바는 StatefulShellRoute로 만든다. branch 하나가 탭 하나이고,
  /// 각 탭은 자기만의 화면 스택을 따로 유지한다.
  /// 탭 위에 겹쳐 띄우는 화면(Page2 등)은 branch 밖의 일반 GoRoute로 둔다.
  static final GoRouter config = GoRouter(
    initialLocation: RoutePath.page1.path,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => NavigationScreen(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.page1.path,
                builder: (context, state) => const Page1Screen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePath.page3.path,
                builder: (context, state) => const Page3Screen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePath.page2.path,
        builder: (context, state) {
          final id = int.parse(state.pathParameters["id"]!);
          return Page2Screen(postId: id);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text("페이지를 찾을 수 없어요: ${state.uri}")),
    ),
  );
}
