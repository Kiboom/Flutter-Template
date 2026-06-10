import "package:flutter/material.dart";
import "package:template/core/theme.dart";

/// 2번 탭 화면. 상태 없이 정적 내용만 있어 StatelessWidget으로 둔다.
/// 탭바 구조를 보여주기 위한 예시이므로, 실제 내용은 직접 채우면 된다.
class Page3Screen extends StatelessWidget {
  const Page3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Page 3")),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.widgets_outlined, size: 64, color: AppColors.gray500),
            SizedBox(height: 12),
            Text("여기에 화면을 만들어 보세요"),
          ],
        ),
      ),
    );
  }
}
