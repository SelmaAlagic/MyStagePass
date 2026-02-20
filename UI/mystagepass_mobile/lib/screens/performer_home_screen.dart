import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_widget.dart';
import '../utils/image_helpers.dart';
import '../widgets/performer_nav_bar.dart';

class PerformerHomeScreen extends StatefulWidget {
  final int userId;

  const PerformerHomeScreen({super.key, required this.userId});

  @override
  State<PerformerHomeScreen> createState() => _PerformerHomeScreenState();
}

class _PerformerHomeScreenState extends State<PerformerHomeScreen> {
  bool _showNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.fetchMyProfile();
    auth.fetchCurrentUserInfo();

    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.refreshUnreadCount(widget.userId);
  }

  void _toggleNotifications() {
    setState(() => _showNotifications = !_showNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: PerformerBottomNavBar(
        selected: PerformerNavItem.home,
        userId: widget.userId,
      ),
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
              bottom: false,
              child: Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final fullName = auth.currentUserInfo?['fullName'] ?? "User";
                  final email = auth.currentUserInfo?['email'] ?? "";

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            _buildAvatar(auth),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(fullName, style: _nameStyle),
                                  Text(email, style: _emailStyle),
                                ],
                              ),
                            ),
                            _buildNotificationIcon(),
                          ],
                        ),
                      ),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                "Welcome, ${fullName.split(' ').first}!",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                child: Column(
                                  children: [
                                    _buildMenuCard(
                                      "My Events",
                                      Icons.event_rounded,
                                      () {},
                                    ),
                                    const SizedBox(height: 20),
                                    _buildMenuCard(
                                      "Statistics",
                                      Icons.analytics_rounded,
                                      () {},
                                    ),
                                    const SizedBox(height: 20),
                                    _buildMenuCard(
                                      "Add New Event",
                                      Icons.add_circle_rounded,
                                      () {},
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          if (_showNotifications)
            NotificationDropdown(
              userId: widget.userId,
              onClose: () => setState(() => _showNotifications = false),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AuthProvider auth) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: auth.profileImageBytes != null
            ? ImageHelpers.getImageFromBytes(
                auth.profileImageBytes,
                height: 46,
                width: 46,
              )
            : const CircleAvatar(
                radius: 23,
                backgroundImage: AssetImage('assets/images/NoProfileImage.png'),
              ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        return InkWell(
          onTap: _toggleNotifications,
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
                  color: Color(0xFF1D235D),
                  size: 22,
                ),
              ),
              if (provider.unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${provider.unreadCount > 9 ? '9+' : provider.unreadCount}',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF1D235D),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF667085),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  final _nameStyle = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  final _emailStyle = const TextStyle(fontSize: 12, color: Colors.white70);
}
