import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  dark,
  light,
  blue,
  purple,
  green,
}

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.dark;
  SharedPreferences? _prefs;

  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _currentTheme == AppTheme.dark || 
                         _currentTheme == AppTheme.blue || 
                         _currentTheme == AppTheme.purple || 
                         _currentTheme == AppTheme.green;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs?.getInt('appTheme') ?? AppTheme.dark.index;
    _currentTheme = AppTheme.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _prefs?.setInt('appTheme', theme.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    // Legacy toggle for backward compatibility
    _currentTheme = _currentTheme == AppTheme.dark ? AppTheme.light : AppTheme.dark;
    await _prefs?.setInt('appTheme', _currentTheme.index);
    notifyListeners();
  }

  ThemeData get themeData {
    switch (_currentTheme) {
      case AppTheme.dark:
        return _darkTheme();
      case AppTheme.light:
        return _lightTheme();
      case AppTheme.blue:
        return _blueTheme();
      case AppTheme.purple:
        return _purpleTheme();
      case AppTheme.green:
        return _greenTheme();
    }
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0D0D),
      primaryColor: const Color(0xFF3B82F6),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF2563EB),
        surface: Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D0D0D),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color(0xFF3B82F6),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF3B82F6),
        secondary: Color(0xFF2563EB),
        surface: Color(0xFFF5F5F5),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  ThemeData _blueTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A1929),
      primaryColor: const Color(0xFF1E88E5),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF42A5F5),
        surface: Color(0xFF132F4C),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A1929),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF132F4C),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _purpleTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF1A0D2E),
      primaryColor: const Color(0xFF9C27B0),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF9C27B0),
        secondary: Color(0xFFBA68C8),
        surface: Color(0xFF2E1A47),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A0D2E),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF2E1A47),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }

  ThemeData _greenTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D1F12),
      primaryColor: const Color(0xFF4CAF50),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50),
        secondary: Color(0xFF66BB6A),
        surface: Color(0xFF1B3A20),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1F12),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1B3A20),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
