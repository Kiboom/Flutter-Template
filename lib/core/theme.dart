import "package:flutter/material.dart";

/// 앱 전역 색상. 새 색이 필요하면 여기에 추가해서 한 곳에서 관리한다.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF5F38C8);
  static const Color primaryLight = Color(0xFFEBE2FF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF171519);

  static const Color gray100 = Color(0xFFF9FAFC);
  static const Color gray300 = Color(0xFFE4E5EA);
  static const Color gray500 = Color(0xFFB2B3B8);
  static const Color gray700 = Color(0xFF78797C);
  static const Color gray900 = Color(0xFF313236);

  static const Color error = Color(0xFFEA2A00);
}

/// MaterialApp에 넘기는 테마. 색·폰트·컴포넌트 기본값을 바꾸려면 여기서 수정한다.
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
    ),
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      centerTitle: true,
    ),
  );
}
