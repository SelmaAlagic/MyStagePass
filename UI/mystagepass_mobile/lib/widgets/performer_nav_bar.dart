import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/performer_home_screen.dart';
import '../screens/performer_update_profile_screen.dart';

enum PerformerNavItem { home, profile }

class PerformerBottomNavBar extends StatelessWidget {
  final PerformerNavItem selected;
  final int userId;

  const PerformerBottomNavBar({
    super.key,
    required this.selected,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.home_rounded,
              label: "Home",
              item: PerformerNavItem.home,
              onTap: () {
                if (selected != PerformerNavItem.home) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          PerformerHomeScreen(userId: userId),
                      transitionDuration: Duration.zero,
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.person_rounded,
              label: "Profile",
              item: PerformerNavItem.profile,
              onTap: () async {
                if (selected != PerformerNavItem.profile) {
                  final auth = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );

                  if (auth.currentUser?.performers == null) {
                    await auth.fetchMyProfile();
                  }

                  final int? pId =
                      auth.currentUser?.performers?.firstOrNull?.performerID;

                  if (pId != null) {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => PerformerProfileScreen(
                          userId: userId,
                          performerId: pId,
                        ),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile data loading...")),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required PerformerNavItem item,
    required VoidCallback onTap,
  }) {
    final isSelected = selected == item;
    final themeColor = const Color(0xFF1D235D);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? themeColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isSelected ? themeColor : Colors.grey[500],
                size: isSelected ? 28 : 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? themeColor : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
