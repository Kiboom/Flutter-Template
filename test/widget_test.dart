import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:template/screen/common/spring_button.dart";

void main() {
  testWidgets("SpringButton을 누르면 onTap이 호출된다", (WidgetTester tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SpringButton(
            enableHaptic: false,
            onTap: () => tapped = true,
            child: const Text("tap me"),
          ),
        ),
      ),
    );
    await tester.tap(find.text("tap me"));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
