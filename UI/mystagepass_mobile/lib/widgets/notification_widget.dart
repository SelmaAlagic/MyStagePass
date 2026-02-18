import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Notification/notification.dart' as Notification;
import '../providers/notification_provider.dart';

class NotificationDropdown extends StatefulWidget {
  final int userId;
  final VoidCallback onClose;

  const NotificationDropdown({
    super.key,
    required this.userId,
    required this.onClose,
  });

  @override
  State<NotificationDropdown> createState() => _NotificationDropdownState();
}

class _NotificationDropdownState extends State<NotificationDropdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  List<Notification.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final provider = Provider.of<NotificationProvider>(context, listen: false);

    final notifications = await provider.getUnreadNotifications(widget.userId);

    if (notifications.isNotEmpty) {
      await provider.markAllAsRead(widget.userId);
    }

    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: GestureDetector(
          onTap: () {},
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 380,
                          maxHeight: 550,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [_buildHeader(), _buildNotificationsList()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D2939),
            ),
          ),
          Row(
            children: [
              if (!_isLoading && _notifications.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(241, 29, 35, 93),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_notifications.length} new',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onClose,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 20, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_isLoading) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          color: Color.fromARGB(241, 29, 35, 93),
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No new notifications',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _NotificationItem(
            notification: _notifications[index],
            onDelete: () async {
              final provider = Provider.of<NotificationProvider>(
                context,
                listen: false,
              );
              await provider.deleteNotification(
                _notifications[index].notificationID!,
              );

              if (mounted) {
                setState(() {
                  _notifications.removeAt(index);
                });
              }
            },
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Notification.Notification notification;
  final VoidCallback onDelete;

  const _NotificationItem({required this.notification, required this.onDelete});

  String? _getPerformerName() {
    final message = notification.message ?? '';
    final startQuote = message.indexOf("'");
    final endQuote = message.lastIndexOf("'");
    if (startQuote != -1 && endQuote != -1 && startQuote < endQuote) {
      return message.substring(startQuote + 1, endQuote);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final performerName = _getPerformerName();
    final message = notification.message ?? 'No message';

    String restOfMessage = message;
    if (performerName != null) {
      final nameIndex = message.indexOf(performerName);
      if (nameIndex != -1) {
        restOfMessage = message.substring(nameIndex + performerName.length + 1);
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.getNotificationColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: notification.getNotificationColor().withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.getNotificationIcon(),
            color: notification.getNotificationColor(),
            size: 22,
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              if (performerName != null)
                TextSpan(
                  text: performerName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: notification.getNotificationColor(),
                  ),
                ),
              TextSpan(
                text: performerName != null ? ' $restOfMessage' : message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                notification.getTimeAgo(),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        trailing: GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 16, color: Colors.red),
          ),
        ),
      ),
    );
  }
}
