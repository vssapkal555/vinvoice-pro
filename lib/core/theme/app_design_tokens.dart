import 'package:flutter/material.dart';

/// Shared VInvoice Pro design-system measurements.
///
/// Screens should use these values instead of introducing random
/// spacing, corner radii, or layout dimensions.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 20);
}

class AppRadius {
  AppRadius._();

  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double pill = 999;
}

class AppSizes {
  AppSizes._();

  static const double touchTarget = 48;
  static const double buttonHeight = 52;
  static const double inputHeight = 52;
  static const double navHeight = 72;
  static const double iconSmall = 18;
  static const double iconMedium = 22;
  static const double iconLarge = 26;
}
