import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Privater Konstruktor
  NotificationService._internal();

  // Statische Instanz für das Singleton-Pattern
  static final NotificationService _instance = NotificationService._internal();

  // Öffentlicher Getter für 'instance' - Behebt die Fehler in main.dart und den Pages
  static NotificationService get instance => _instance;

  // Factory Konstruktor, falls man NotificationService() statt .instance aufruft
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();
    // Wichtig: Die lokale Zeitzone muss gesetzt sein
    tz.setLocalLocation(tz.getLocation('Europe/Vienna'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // In neueren Android-Versionen getrennte Anfragen
    final androidGranted = await androidPlugin
        ?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidGranted ?? iosGranted ?? true;
  }

  Future<void> scheduleTaskNotification({
    required String taskId,
    required String title,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;

    final hasPermission = await requestPermissions();
    if (!hasPermission) return;

    final now = DateTime.now();
    // Sicherstellen, dass das Datum nicht in der Vergangenheit liegt
    final safeScheduledDate = scheduledDate.isBefore(now)
        ? now.add(const Duration(seconds: 10))
        : scheduledDate;

    // In Version 19.x wurde 'uiLocalNotificationDateInterpretation' entfernt!
    await _notifications.zonedSchedule(
      taskId.hashCode,
      'Termin Erinnerung',
      title,
      tz.TZDateTime.from(safeScheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Termin-Erinnerungen',
          channelDescription: 'Erinnerungen für geplante Termine und Aufgaben',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // 'androidScheduleMode' ist jetzt der entscheidende Parameter für Pünktlichkeit
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskNotification(String taskId) async {
    if (kIsWeb) return;
    await _notifications.cancel(taskId.hashCode);
  }
}
