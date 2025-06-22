import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  static const String _isFirstRunKey = 'is_first_run';
  static const String _lastNotificationUpdateKey = 'last_notification_update';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstRunKey) ?? true;
  }

  Future<void> setFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstRunKey, false);
  }

  Future<DateTime?> getLastNotificationUpdate() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getString(_lastNotificationUpdateKey);
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  Future<void> setLastNotificationUpdate(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastNotificationUpdateKey, dateTime.toIso8601String());
  }

  Future<String> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'system';
  }

  Future<void> setThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }
}
