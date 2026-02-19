import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/screens/customer_home_screen.dart';
import 'package:mystagepass_mobile/screens/favorites_screen.dart';

enum NavItem { home, favorites, tickets, profile }

class BottomNavBar extends StatelessWidget {
  final NavItem selected;
  final int userId;
  final VoidCallback? onProfileTap;

  const BottomNavBar({
    super.key,
    required this.selected,
    required this.userId,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
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
              item: NavItem.home,
              onTap: () {
                if (selected != NavItem.home) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          CustomerHomeScreen(userId: userId),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.favorite_rounded,
              label: "Favorites",
              item: NavItem.favorites,
              onTap: () {
                if (selected != NavItem.favorites) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          FavoritesScreen(userId: userId),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context,
              icon: Icons.confirmation_number_rounded,
              label: "Tickets",
              item: NavItem.tickets,
              onTap: () {},
            ),
            _buildNavItem(
              context,
              icon: Icons.person_rounded,
              label: "Profile",
              item: NavItem.profile,
              onTap: () => onProfileTap?.call(),
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
    required NavItem item,
    required VoidCallback onTap,
  }) {
    final isSelected = selected == item;
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color.fromARGB(241, 29, 35, 93).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? const Color.fromARGB(241, 29, 35, 93)
                    : Colors.grey[500],
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? const Color.fromARGB(241, 29, 35, 93)
                    : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
