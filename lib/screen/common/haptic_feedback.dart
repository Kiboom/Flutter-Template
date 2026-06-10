import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:gaimon/gaimon.dart";

/// 터치 시 진동(햅틱) 피드백을 주는 헬퍼. iOS에서만 동작하고 그 외 플랫폼에선 무시된다.
/// 버튼을 누를 때 `AppHaptic.selection()` 처럼 호출한다.
class AppHaptic {
  AppHaptic._();

  static Future<bool> _canSupport() async => !kIsWeb && Platform.isIOS && (await Gaimon.canSupportsHaptic);

  static void selection() async {
    if (await _canSupport()) HapticFeedback.selectionClick();
  }

  static void light() async {
    if (await _canSupport()) HapticFeedback.lightImpact();
  }

  static void medium() async {
    if (await _canSupport()) Gaimon.medium();
  }

  static void heavy() async {
    if (await _canSupport()) Gaimon.heavy();
  }

  static void success() async {
    if (await _canSupport()) Gaimon.success();
  }

  static void warning() async {
    if (await _canSupport()) Gaimon.warning();
  }

  static void error() async {
    if (await _canSupport()) Gaimon.error();
  }
}
