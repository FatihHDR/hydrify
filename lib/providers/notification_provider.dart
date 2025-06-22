import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/notification_models.dart';

class NotificationProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  NotificationSettings _settings = NotificationSettings();
  bool _isInitialized = false;

  NotificationSettings get settings => _settings;
  bool get isInitialized => _isInitialized;

  NotificationProvider() {
    _initializeNotifications();
    _loadSettings();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    _isInitialized = true;
    notifyListeners();
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap
    print('Notification tapped: ${notificationResponse.payload}');
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('notification_settings');
    
    if (settingsJson != null) {
      _settings = NotificationSettings.fromJson(json.decode(settingsJson));
    }
    
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(_settings.toJson());
    await prefs.setString('notification_settings', settingsJson);
  }

  Future<bool> requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    }
    return true;
  }

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    
    if (_settings.enabled) {
      await scheduleNotifications();
    } else {
      await cancelAllNotifications();
    }
    
    notifyListeners();
  }

  Future<void> scheduleNotifications() async {
    if (!_settings.enabled || !_isInitialized) return;
    
    await cancelAllNotifications();
    
    final now = DateTime.now();
    final startTime = _parseTime(_settings.startTime);
    final endTime = _parseTime(_settings.endTime);
    
    DateTime nextNotification = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );
    
    // If start time is in the past today, start from tomorrow
    if (nextNotification.isBefore(now)) {
      nextNotification = nextNotification.add(const Duration(days: 1));
    }
    
    int notificationId = 0;
    
    // Schedule notifications for the next 7 days
    for (int day = 0; day < 7; day++) {
      final dayStart = nextNotification.add(Duration(days: day));
      final dayEnd = DateTime(
        dayStart.year,
        dayStart.month,
        dayStart.day,
        endTime.hour,
        endTime.minute,
      );
      
      DateTime currentTime = dayStart;
      
      while (currentTime.isBefore(dayEnd)) {
        await _scheduleNotification(
          notificationId++,
          currentTime,
          _getRandomMessage(),
        );
        
        currentTime = currentTime.add(Duration(minutes: _settings.intervalMinutes));
      }
    }
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    return DateTime(0, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _getRandomMessage() {
    final random = Random();
    return _settings.customMessages[random.nextInt(_settings.customMessages.length)];
  }

  Future<void> _scheduleNotification(int id, DateTime scheduledTime, String message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hydrify_reminders',
      'Water Reminders',
      channelDescription: 'Reminders to drink water',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Water Reminder',
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Hydrify',
      message,
      scheduledTime,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'water_reminder',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showInstantReminder() async {
    if (!_isInitialized) return;
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'hydrify_instant',
      'Instant Reminders',
      channelDescription: 'Instant water reminders',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Drink Water Now!',
      icon: '@mipmap/ic_launcher',
    );
    
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    
    await _flutterLocalNotificationsPlugin.show(
      999,
      'Hydrify',
      _getRandomMessage(),
      platformChannelSpecifics,
      payload: 'instant_reminder',
    );
  }
}
