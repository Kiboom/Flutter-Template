import "dart:async";

import "package:flutter/material.dart";
import "package:template/core/app.dart";
import "package:template/core/logger.dart";

/// 앱 진입점. 바인딩 초기화, 전역 에러 처리, runApp을 한 곳에서 담당한다.
/// 초기화할 것(예: SharedPreferences, Firebase)이 생기면 [_initialize]에 추가하면 된다.
class AppRunner {
  const AppRunner._();

  static Future<void> run() async {
    runZonedGuarded(
      () async {
        WidgetsFlutterBinding.ensureInitialized();
        await _initialize();
        runApp(const App());
      },
      (error, stack) => logger.e("Uncaught error", error: error, stack: stack),
    );
  }

  static Future<void> _initialize() async {}
}
