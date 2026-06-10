import "package:flutter/material.dart";
import "package:template/core/routes.dart";
import "package:template/core/theme.dart";

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Template",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRoutes.config,
    );
  }
}
