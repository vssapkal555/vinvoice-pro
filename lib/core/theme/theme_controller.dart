import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VInvoiceTheme {
  professionalBlue(
    'professionalBlue',
    'Professional Blue',
    Color(0xFF2563EB),
    Color(0xFF0EA5E9),
    Color(0xFFEEF6FF),
  ),
  tealSky(
    'tealSky',
    'Teal Sky',
    Color(0xFF0F9D8A),
    Color(0xFF38BDF8),
    Color(0xFFECFDF9),
  ),
  indigoLavender(
    'indigoLavender',
    'Indigo Lavender',
    Color(0xFF6366F1),
    Color(0xFFA78BFA),
    Color(0xFFF4F3FF),
  );

  const VInvoiceTheme(
    this.key,
    this.label,
    this.primary,
    this.secondary,
    this.soft,
  );

  final String key;
  final String label;
  final Color primary;
  final Color secondary;
  final Color soft;

  static VInvoiceTheme fromKey(String? key) {
    switch (key) {
      case 'blue':
      case 'navy':
        return VInvoiceTheme.professionalBlue;
      case 'teal':
      case 'emerald':
        return VInvoiceTheme.tealSky;
      case 'purple':
        return VInvoiceTheme.indigoLavender;
      default:
        return values.firstWhere(
          (value) => value.key == key,
          orElse: () => VInvoiceTheme.professionalBlue,
        );
    }
  }
}

class VInvoiceThemeController extends ChangeNotifier {
  static const _preferenceKey = 'vinvoice_theme';

  VInvoiceTheme _theme = VInvoiceTheme.professionalBlue;
  bool _loaded = false;

  VInvoiceTheme get theme => _theme;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _theme = VInvoiceTheme.fromKey(prefs.getString(_preferenceKey));
    _loaded = true;
    notifyListeners();
  }

  Future<void> setTheme(VInvoiceTheme value) async {
    if (_theme == value && _loaded) return;

    _theme = value;
    _loaded = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, value.key);
  }
}

final appThemeController = VInvoiceThemeController();
