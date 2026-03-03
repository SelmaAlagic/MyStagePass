import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mystagepass_admin/providers/auth_provider.dart';
import 'package:mystagepass_admin/providers/notification_provider.dart';
import 'package:mystagepass_admin/providers/user_provider.dart';
import 'package:mystagepass_admin/utils/image_helpers.dart';
import 'package:mystagepass_admin/widgets/notification_widget.dart';

class BaseLayout extends StatefulWidget {
  final int userId;
  final Widget child;

  const BaseLayout({super.key, required this.userId, required this.child});

  @override
  State<BaseLayout> createState() => _BaseLayoutState();
}

class _BaseLayoutState extends State<BaseLayout> {
  bool _showNotifications = false;
  String _fullName = "";
  String _email = "";
  String? _profileImage;
  bool _isLoadingUserData = true;
  final UserProvider _userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationCount();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? firstName = await authProvider.getCurrentUserFirstName();
    String? lastName = await authProvider.getCurrentUserLastName();
    String? email = await authProvider.getCurrentUserEmail();

    try {
      var user = await _userProvider.getById(widget.userId);
      if (mounted) {
        setState(() {
          _profileImage = user.image;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    if (mounted) {
      setState(() {
        if (firstName != null && lastName != null) {
          _fullName = "$firstName $lastName";
        }
        if (email != null) _email = email;
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _loadNotificationCount() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.refreshUnreadCount(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: _profileImage != null
                                    ? ImageHelpers.getImage(
                                        _profileImage!,
                                        height: 46,
                                        width: 46,
                                      )
                                    : const CircleAvatar(
                                        radius: 23,
                                        backgroundImage: AssetImage(
                                          'assets/images/NoProfileImage.png',
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _isLoadingUserData
                                ? const SizedBox(
                                    width: 120,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 14,
                                          width: 90,
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white54,
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        SizedBox(
                                          height: 12,
                                          width: 120,
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white54,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fullName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _email,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        _buildNotificationButton(),
                      ],
                    ),
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ),
          if (_showNotifications)
            NotificationDropdown(
              userId: widget.userId,
              onViewAll: () {},
              onClose: () => setState(() => _showNotifications = false),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return InkWell(
          onTap: () => setState(() => _showNotifications = !_showNotifications),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color.fromARGB(255, 29, 35, 93),
                  size: 20,
                ),
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        notificationProvider.unreadCount > 9
                            ? '9+'
                            : '${notificationProvider.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
