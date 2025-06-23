import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.light;
  bool _isAnimating = false;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isAnimating => _isAnimating;
  
  ThemeManager() {
    _loadTheme();
  }
  
  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  Future<void> toggleTheme() async {
    _isAnimating = true;
    notifyListeners();
    
    // Add a small delay for smooth animation
    await Future.delayed(const Duration(milliseconds: 100));
    
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    
    _isAnimating = false;
    notifyListeners();
  }
  
  Future<void> setTheme(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;
    
    _isAnimating = true;
    notifyListeners();
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    _themeMode = themeMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _themeMode == ThemeMode.dark);
    
    _isAnimating = false;
    notifyListeners();
  }
}
