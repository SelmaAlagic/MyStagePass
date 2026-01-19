import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Notification/notification.dart';
import 'base_provider.dart';

class NotificationProvider extends BaseProvider<Notification> {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  NotificationProvider() : super("api/Notification");

  @override
  Notification fromJson(data) {
    return Notification.fromJson(data);
  }

  Future<List<Notification>> getForUser(int userId, {bool? isRead}) async {
    var url = "${getBaseUrl()}api/Notification?UserID=$userId";

    if (isRead != null) {
      url = "$url&IsRead=$isRead";
    }

    final uri = Uri.parse(url);
    final headers = await createHeaders();
    final response = await http.get(uri, headers: headers);

    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      var notificationsList = data is List ? data : (data['result'] ?? []);

      return notificationsList
          .map<Notification>((json) => Notification.fromJson(json))
          .toList();
    }
    return [];
  }

  Future<int> getUnreadCount(int userId) async {
    final url = Uri.parse(
      "${getBaseUrl()}api/Notification/unread-count/$userId",
    );
    final headers = await createHeaders();
    final response = await http.get(url, headers: headers);

    if (isValidResponse(response)) {
      _unreadCount = int.parse(response.body);
      notifyListeners();
      return _unreadCount;
    }
    return 0;
  }

  Future<void> markAllAsRead(int userId) async {
    final url = Uri.parse(
      "${getBaseUrl()}api/Notification/mark-all-as-read/$userId",
    );
    final headers = await createHeaders();

    final response = await http.put(url, headers: headers);

    if (isValidResponse(response)) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    await delete(notificationId);
    if (_unreadCount > 0) {
      _unreadCount--;
    }
    notifyListeners();
  }

  Future<List<Notification>> getUnreadNotifications(int userId) async {
    return await getForUser(userId, isRead: false);
  }

  Future<List<Notification>> getAllNotifications(int userId) async {
    return await getForUser(userId);
  }

  Future<void> refreshUnreadCount(int userId) async {
    await getUnreadCount(userId);
  }
}
