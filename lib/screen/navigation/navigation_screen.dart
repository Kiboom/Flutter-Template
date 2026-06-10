import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

/// 하단 탭바를 그리는 화면. 각 탭의 내용은 [navigationShell]이 들고 있고,
/// 이 화면은 탭을 눌렀을 때 화면을 전환하는 역할만 한다.
/// 탭을 추가하려면 (1) 여기 destinations와 (2) routes.dart의 branches를 같이 늘린다.
class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      // 이미 선택된 탭을 다시 누르면 그 탭의 첫 화면으로 돌아간다.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.looks_one_outlined),
            selectedIcon: Icon(Icons.looks_one),
            label: "Page 1",
          ),
          NavigationDestination(
            icon: Icon(Icons.looks_3_outlined),
            selectedIcon: Icon(Icons.looks_3),
            label: "Page 3",
          ),
        ],
      ),
    );
  }
}
