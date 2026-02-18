import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../User/user.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  int? notificationID;
  int? userID;
  User? user;
  String? message;
  DateTime? createdAt;
  bool? isRead;
  bool? isDeleted;

  Notification({
    this.notificationID,
    this.userID,
    this.user,
    this.message,
    this.createdAt,
    this.isRead,
    this.isDeleted,
  });

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  String getTimeAgo() {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${createdAt!.day} ${months[createdAt!.month - 1]}';
    }
  }

  IconData getNotificationIcon() {
    if (message == null) return Icons.notifications;

    final msg = message!.toLowerCase();
    if (msg.contains('performer')) {
      return Icons.person;
    } else if (msg.contains('event')) {
      return Icons.event;
    } else if (msg.contains('user')) {
      return Icons.people;
    } else if (msg.contains('approval') || msg.contains('verification')) {
      return Icons.check_circle_outline;
    }
    return Icons.notifications;
  }

  Color getNotificationColor() {
    if (message == null) return const Color(0xFF5865F2);

    final msg = message!.toLowerCase();
    if (msg.contains('performer')) {
      return Colors.purple;
    } else if (msg.contains('event')) {
      return Colors.blue;
    } else if (msg.contains('user')) {
      return Colors.green;
    } else if (msg.contains('approval') || msg.contains('verification')) {
      return Colors.orange;
    }
    return const Color(0xFF5865F2);
  }
}
