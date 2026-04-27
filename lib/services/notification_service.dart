import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/item_model.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> checkAndNotifyStaleItems(
      List<ItemModel> items, {
        int thresholdDays = 7,
      }) async {
    final stale = items
        .where((i) =>
    i.status == ItemStatus.watching && i.daysOnList >= thresholdDays)
        .toList();

    for (final item in stale) {
      await _sendNotification(item);
    }
  }

  Future<void> _sendNotification(ItemModel item) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'watchlist_channel',
        'Watchlist Reminders',
        channelDescription: 'Reminders for items sitting in your watchlist',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
    );

    await _plugin.show(
      item.id.hashCode.abs() % 2147483647,
      'Still eyeing ${item.name}?',
      "It's been ${item.daysOnList} days since you spotted it at ${item.locLabel}!",
      details,
    );
  }
}