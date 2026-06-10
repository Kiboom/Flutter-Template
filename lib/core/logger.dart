import "package:flutter/foundation.dart";

/// 앱 어디서나 `logger.d(...)` 처럼 쓰는 전역 로거.
/// 릴리즈 빌드에서는 아무것도 출력하지 않는다.
final AppLogger logger = AppLogger();

class AppLogger {
  void d(Object? message) => _print("DEBUG", message);

  void i(Object? message) => _print("INFO", message);

  void w(Object? message) => _print("WARN", message);

  void e(Object? message, {Object? error, StackTrace? stack}) {
    _print("ERROR", message);
    if (error != null) _print("ERROR", error);
    if (stack != null) _print("ERROR", stack);
  }

  void _print(String level, Object? message) {
    if (!kDebugMode) return;
    debugPrint("[$level] $message");
  }
}
