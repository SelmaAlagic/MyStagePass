import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/notification_widget.dart';
import '../utils/image_helpers.dart';
import '../utils/alert_helpers.dart';
import 'login_screen.dart';

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
      auth.fetchMyProfile();
      if (auth.currentUserInfo == null) {
        auth.fetchCurrentUserInfo();
      }
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
        onProfileTap: _showProfileMenu,
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
                  final profileImage = auth.currentUser?.image;

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
                                child: profileImage != null
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

  void _showProfileMenu() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final fullName = auth.currentUserInfo?['fullName'] ?? "User";
    final email = auth.currentUserInfo?['email'] ?? "";
    final profileImage = auth.currentUser?.image;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(241, 29, 35, 93),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: profileImage != null
                            ? ImageHelpers.getImage(
                                profileImage,
                                height: 60,
                                width: 60,
                              )
                            : const CircleAvatar(
                                radius: 30,
                                backgroundImage: AssetImage(
                                  'assets/images/NoProfileImage.png',
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D2939),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey[200]),
              _buildProfileMenuItem(
                icon: Icons.person_outline_rounded,
                label: "Edit Profile",
                onTap: () => Navigator.pop(context),
              ),
              _buildProfileMenuItem(
                icon: Icons.settings_outlined,
                label: "Settings",
                onTap: () => Navigator.pop(context),
              ),
              _buildProfileMenuItem(
                icon: Icons.help_outline_rounded,
                label: "Help & Support",
                onTap: () => Navigator.pop(context),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              _buildProfileMenuItem(
                icon: Icons.logout_rounded,
                label: "Logout",
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(auth);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF1D2939),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : const Color(0xFF1D2939),
                ),
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider auth) {
    AlertHelpers.showConfirmationAlert(
      context,
      "Logout",
      "Are you sure you want to logout?",
      confirmButtonText: "Logout",
      cancelButtonText: "Cancel",
      isDelete: true,
      onConfirm: () async {
        await auth.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}
