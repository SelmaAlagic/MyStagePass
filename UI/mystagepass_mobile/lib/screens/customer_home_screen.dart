import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_widget.dart';
import '../utils/image_helpers.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int userId;

  const CustomerHomeScreen({super.key, required this.userId});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _showNotifications = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser == null) auth.fetchMyProfile();
      if (auth.currentUserInfo == null) auth.fetchCurrentUserInfo();
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      notificationProvider.refreshUnreadCount(widget.userId);
    });
  }

  void _toggleNotifications() {
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.home,
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
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
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
                                        backgroundImage: AssetImage(
                                          'assets/images/NoProfileImage.png',
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Consumer<NotificationProvider>(
                              builder: (context, notificationProvider, _) {
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
                                          color: Color.fromARGB(
                                            255,
                                            29,
                                            35,
                                            93,
                                          ),
                                          size: 22,
                                        ),
                                      ),
                                      if (notificationProvider.unreadCount > 0)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                            ),
                                            height: 18,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                            ),
                                            child: Center(
                                              child: Text(
                                                notificationProvider
                                                            .unreadCount >
                                                        9
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
                            ),
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
                                      "Recommended",
                                      Icons.recommend_rounded,
                                      () {},
                                    ),
                                    const SizedBox(height: 20),
                                    _buildMenuCard(
                                      "Upcoming Events",
                                      Icons.schedule_rounded,
                                      () {},
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 80),
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
              onClose: () {
                setState(() {
                  _showNotifications = false;
                });
              },
            ),
        ],
      ),
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
                color: Color.fromARGB(241, 29, 35, 93),
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
}
