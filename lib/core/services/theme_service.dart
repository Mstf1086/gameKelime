import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeKey = 'theme_mode';
const String _themeLight = 'light';
const String _themeDark = 'dark';

/// Tema (açık/koyu mod) yönetimi. localStorage'da tercih saklanır.
class ThemeService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    if (saved == _themeDark) {
      _themeMode = ThemeMode.dark;
    } else if (saved == _themeLight) {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> init() async {
    await _loadTheme();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.dark) {
      await prefs.setString(_themeKey, _themeDark);
    } else if (mode == ThemeMode.light) {
      await prefs.setString(_themeKey, _themeLight);
    } else {
      await prefs.remove(_themeKey);
    }
    notifyListeners();
  }

  void toggleTheme() {
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(newMode);
  }
}
