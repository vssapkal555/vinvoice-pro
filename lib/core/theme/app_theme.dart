import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ================================================================
  // VINVOICE PRO BRAND
  // ================================================================

  /// Main VInvoice brand blue.
  static const Color primary = Color(0xFF2563EB);

  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFEFF6FF);

  /// Strong finance/product brand tone.
  static const Color brandNavy = Color(0xFF101828);

  // ================================================================
  // NEUTRALS
  // ================================================================

  static const Color darkText = Color(0xFF0F172A);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color tertiaryText = Color(0xFF94A3B8);

  static const Color background = Color(0xFFF6F8FC);

  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF8FAFC);
  static const Color surfaceMuted = Color(0xFFF1F5F9);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // ================================================================
  // SEMANTIC COLORS
  // ================================================================

  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFF7ED);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEF2F2);

  static const Color info = Color(0xFF0284C7);
  static const Color infoSoft = Color(0xFFF0F9FF);

  // ================================================================
  // THEME
  // ================================================================

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: primarySoft,
      onPrimaryContainer: primaryDark,
      secondary: brandNavy,
      onSecondary: Colors.white,
      secondaryContainer: surfaceMuted,
      onSecondaryContainer: darkText,
      tertiary: info,
      onTertiary: Colors.white,
      tertiaryContainer: infoSoft,
      onTertiaryContainer: darkText,
      error: danger,
      onError: Colors.white,
      errorContainer: dangerSoft,
      onErrorContainer: danger,
      surface: surface,
      onSurface: darkText,
      surfaceContainerHighest: surfaceMuted,
      onSurfaceVariant: secondaryText,
      outline: borderStrong,
      outlineVariant: border,
      shadow: Color(0x140F172A),
      scrim: Color(0x660F172A),
      inverseSurface: brandNavy,
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF93C5FD),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',

      visualDensity: VisualDensity.standard,

      // --------------------------------------------------------------
      // TYPOGRAPHY
      // --------------------------------------------------------------
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 36,
          height: 1.15,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.0,
          color: darkText,
        ),
        headlineLarge: TextStyle(
          fontSize: 30,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
          color: darkText,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          height: 1.2,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: darkText,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          height: 1.25,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: darkText,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.35,
          fontWeight: FontWeight.w700,
          color: darkText,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          height: 1.35,
          fontWeight: FontWeight.w600,
          color: darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: darkText,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: darkText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),

      // --------------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------------
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: darkText,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        iconTheme: IconThemeData(color: darkText, size: 22),
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),

      // --------------------------------------------------------------
      // CARDS
      // --------------------------------------------------------------
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: border, width: 1),
        ),
      ),

      // --------------------------------------------------------------
      // INPUTS
      // --------------------------------------------------------------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        hintStyle: const TextStyle(color: tertiaryText, fontSize: 14),
        labelStyle: const TextStyle(
          color: secondaryText,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          color: primary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: secondaryText,
        suffixIconColor: secondaryText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: danger, width: 1.5),
        ),
      ),

      // --------------------------------------------------------------
      // FILLED BUTTON
      // --------------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          foregroundColor: Colors.white,
          backgroundColor: primary,
          disabledBackgroundColor: surfaceMuted,
          disabledForegroundColor: tertiaryText,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      // --------------------------------------------------------------
      // ELEVATED BUTTON
      // Backward compatibility for existing screens.
      // --------------------------------------------------------------
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 52),
          foregroundColor: Colors.white,
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      // --------------------------------------------------------------
      // OUTLINED BUTTON
      // --------------------------------------------------------------
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(0, 50),
          foregroundColor: darkText,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          side: const BorderSide(color: borderStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // --------------------------------------------------------------
      // TEXT BUTTON
      // --------------------------------------------------------------
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // --------------------------------------------------------------
      // CHIPS
      // --------------------------------------------------------------
      chipTheme: ChipThemeData(
        elevation: 0,
        pressElevation: 0,
        backgroundColor: surface,
        selectedColor: primarySoft,
        disabledColor: surfaceMuted,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: const TextStyle(
          color: secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(
          color: primaryDark,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),

      // --------------------------------------------------------------
      // BOTTOM NAVIGATION
      // --------------------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primarySoft,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }

          return const IconThemeData(color: secondaryText, size: 23);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            );
          }

          return const TextStyle(
            color: secondaryText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          );
        }),
      ),

      // --------------------------------------------------------------
      // FLOATING ACTION BUTTON
      // --------------------------------------------------------------
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 3,
        foregroundColor: Colors.white,
        backgroundColor: primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),

      // --------------------------------------------------------------
      // DIVIDERS
      // --------------------------------------------------------------
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),

      // --------------------------------------------------------------
      // SNACKBARS
      // --------------------------------------------------------------
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: brandNavy,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // --------------------------------------------------------------
      // PROGRESS
      // --------------------------------------------------------------
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceMuted,
      ),

      // --------------------------------------------------------------
      // SELECTION
      // --------------------------------------------------------------
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }

          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }

          return borderStrong;
        }),
      ),
    );
  }
}
