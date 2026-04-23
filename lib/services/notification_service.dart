import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'mutuo_channel',
      'Lembretes Mútuo',
      channelDescription: 'Notificações de vencimento do mútuo',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    ),
  );

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await notificationsPlugin.initialize(
      const InitializationSettings(android: android),
    );

    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        'mutuo_channel',
        'Lembretes Mútuo',
        description: 'Notificações de vencimento do mútuo',
        importance: Importance.max,
      ),
    );

    await androidPlugin?.requestNotificationsPermission();
  }

  Future<bool> _canScheduleExact() async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    return await androidPlugin?.canScheduleExactNotifications() ?? false;
  }

  Future<void> requestExactAlarmPermission() async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  Future<void> scheduleNotifications(DateTime nextDate) async {
    await notificationsPlugin.cancelAll();

    final canExact = await _canScheduleExact();
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final notifications = [
      (id: 0, date: nextDate.subtract(const Duration(days: 7)), body: 'Faltam 7 dias para o vencimento do mútuo. Prepare-se!'),
      (id: 1, date: nextDate.subtract(const Duration(days: 3)), body: 'Faltam apenas 3 dias para o vencimento do mútuo!'),
      (id: 2, date: nextDate, body: '⚠️ Hoje é o dia do vencimento do mútuo!'),
    ];

    final now = DateTime.now();
    for (final n in notifications) {
      if (n.date.isAfter(now)) {
        await notificationsPlugin.zonedSchedule(
          n.id,
          'Lembrete Mútuo',
          n.body,
          tz.TZDateTime.from(n.date, tz.local),
          _details,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: mode,
        );
      }
    }
  }

  Future<void> scheduleTestNotifications() async {
    await notificationsPlugin.cancel(10);
    await notificationsPlugin.cancel(11);
    await notificationsPlugin.cancel(12);

    final canExact = await _canScheduleExact();
    final mode = canExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final now = DateTime.now();
    final tests = [
      (id: 10, delay: 10, body: 'Faltam 7 dias para o vencimento do mútuo. Prepare-se!'),
      (id: 11, delay: 20, body: 'Faltam apenas 3 dias para o vencimento do mútuo!'),
      (id: 12, delay: 30, body: '⚠️ Hoje é o dia do vencimento do mútuo!'),
    ];

    for (final t in tests) {
      await notificationsPlugin.zonedSchedule(
        t.id,
        'Lembrete Mútuo',
        t.body,
        tz.TZDateTime.from(now.add(Duration(seconds: t.delay)), tz.local),
        _details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: mode,
      );
    }
  }
}
