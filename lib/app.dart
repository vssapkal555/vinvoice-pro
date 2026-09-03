import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

class VInvoiceApp extends StatefulWidget {
  const VInvoiceApp({super.key});

  @override
  State<VInvoiceApp> createState() => _VInvoiceAppState();
}

class _VInvoiceAppState extends State<VInvoiceApp> {
  @override
  void initState() {
    super.initState();
    appThemeController.load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appThemeController,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'VInvoice Pro',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeFor(appThemeController.theme),
          routerConfig: appRouter,
        );
      },
    );
  }
}
