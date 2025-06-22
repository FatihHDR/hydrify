import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/user_profile_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
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

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> scheduleWaterReminders(UserProfileModel profile) async {
    if (!profile.notificationsEnabled) return;

    // Cancel existing notifications
    await _flutterLocalNotificationsPlugin.cancelAll();

    // Calculate notification times
    final startTime = profile.startTime;
    final endTime = profile.endTime;
    final interval = profile.notificationInterval;

    final notifications = _calculateNotificationTimes(startTime, endTime, interval);

    for (int i = 0; i < notifications.length; i++) {
      await _scheduleNotification(
        id: i,
        title: '💧 Time to hydrate!',
        body: _getRandomReminderMessage(),
        scheduledTime: notifications[i],
      );
    }
  }

  List<DateTime> _calculateNotificationTimes(
      DateTime startTime, DateTime endTime, int intervalMinutes) {
    final List<DateTime> times = [];
    final now = DateTime.now();
    
    DateTime currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    while (currentTime.isBefore(endDateTime)) {
      if (currentTime.isAfter(now)) {
        times.add(currentTime);
      }
      currentTime = currentTime.add(Duration(minutes: intervalMinutes));
    }

    return times;
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_reminder_channel',
      'Water Reminders',
      channelDescription: 'Notifications to remind you to drink water',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      payload: 'water_reminder',
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String _getRandomReminderMessage() {
    final messages = [
      'Stay hydrated! Your body needs water 🌊',
      'Time for a refreshing glass of water! 💧',
      'Don\'t forget to drink water - your health depends on it! 🥤',
      'Hydration check! Time to drink some water 💦',
      'Your body is calling for water! Listen to it 🚰',
      'Keep the flow going - drink water now! 🌊',
      'Water break time! Your future self will thank you 💧',
      'Boost your energy with a glass of water! ⚡',
    ];
    
    return messages[(DateTime.now().millisecondsSinceEpoch % messages.length)];
  }

  Future<void> showInstantReminder() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'instant_reminder_channel',
      'Instant Reminders',
      channelDescription: 'Instant water drinking reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      999,
      '💧 Hydration Reminder',
      'Great job logging your water intake! Keep it up! 🎉',
      platformChannelSpecifics,
      payload: 'water_logged',
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
