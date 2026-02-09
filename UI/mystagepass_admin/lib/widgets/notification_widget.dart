import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Notification/notification.dart' as NotificationModel;
import '../providers/notification_provider.dart';

class NotificationDropdown extends StatefulWidget {
  final int userId;
  final VoidCallback onViewAll;
  final VoidCallback onClose;

  const NotificationDropdown({
    super.key,
    required this.userId,
    required this.onViewAll,
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
  List<NotificationModel.Notification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
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

    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
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
        color: Colors.black.withOpacity(0.5),
        child: GestureDetector(
          onTap: () {},
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      width: 480,
                      constraints: const BoxConstraints(
                        maxHeight: 600,
                        maxWidth: 400,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          _buildNotificationsList(),
                          if (_notifications.isNotEmpty) _buildFooter(),
                        ],
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
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
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
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    '${_notifications.length} new',
                    style: TextStyle(
                      color: Colors.red.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.close, size: 22),
                color: Colors.grey.shade600,
                onPressed: widget.onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
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
        height: 400,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.red),
      );
    }

    if (_notifications.isEmpty) {
      return Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No new notifications',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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

    final displayNotifications = _notifications.take(5).toList();

    return Flexible(
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: displayNotifications.length,
        itemBuilder: (context, index) {
          return _NotificationItem(
            notification: displayNotifications[index],
            onDelete: () async {
              final provider = Provider.of<NotificationProvider>(
                context,
                listen: false,
              );
              await provider.deleteNotification(
                displayNotifications[index].notificationID!,
              );
              setState(() {
                _notifications.removeAt(index);
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: InkWell(
        onTap: () {
          widget.onClose();
          widget.onViewAll();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              'View All Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final NotificationModel.Notification notification;
  final VoidCallback onDelete;

  const _NotificationItem({required this.notification, required this.onDelete});

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _isHovered = false;

  String? _getFullName() {
    final message = widget.notification.message ?? '';
    final startQuote = message.indexOf("'");
    final endQuote = message.lastIndexOf("'");
    if (startQuote != -1 && endQuote != -1 && startQuote < endQuote) {
      return message.substring(startQuote + 1, endQuote);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _getFullName();
    final message = widget.notification.message ?? 'No message';

    String restOfMessage = message;
    if (fullName != null) {
      restOfMessage = message.substring(fullName.length).trim();
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _isHovered ? Colors.red.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: _isHovered
              ? Border.all(color: Colors.red.shade200, width: 1)
              : null,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.notification.getNotificationIcon(),
              color: Colors.red.shade700,
              size: 20,
            ),
          ),
          title: RichText(
            text: TextSpan(
              children: [
                if (fullName != null)
                  TextSpan(
                    text: fullName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                TextSpan(
                  text: fullName != null ? ' $restOfMessage' : message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  widget.notification.getTimeAgo(),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          trailing: _isHovered
              ? IconButton(
                  icon: Icon(Icons.close, size: 18, color: Colors.red.shade700),
                  onPressed: widget.onDelete,
                  tooltip: 'Dismiss',
                )
              : Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.red.shade500,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }
}
