import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/screens/customer_home_screen.dart';
import 'package:mystagepass_mobile/screens/favorites_screen.dart';
import 'package:mystagepass_mobile/screens/customer_update_profile_screen.dart';
import 'package:mystagepass_mobile/screens/customer_purchases_screen.dart';

enum NavItem { home, favorites, purchases, profile }

class BottomNavBar extends StatelessWidget {
  final NavItem selected;
  final int userId;

  const BottomNavBar({super.key, required this.selected, required this.userId});

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
              activeIcon: Icons.home_rounded,
              inactiveIcon: Icons.home_outlined,
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
              activeIcon: Icons.favorite_rounded,
              inactiveIcon: Icons.favorite_border_rounded,
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
              activeIcon: Icons.shopping_cart_rounded,
              inactiveIcon: Icons.shopping_cart_outlined,
              label: "Purchases",
              item: NavItem.purchases,
              onTap: () {
                if (selected != NavItem.purchases) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          PurchasesScreen(userId: userId),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }
              },
            ),
            _buildNavItem(
              context,
              activeIcon: Icons.person_rounded,
              inactiveIcon: Icons.person_outline_rounded,
              label: "Profile",
              item: NavItem.profile,
              onTap: () {
                if (selected != NavItem.profile) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          ProfileScreen(userId: userId),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
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
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required NavItem item,
    required VoidCallback onTap,
  }) {
    final isSelected = selected == item;
    const primaryColor = Color.fromARGB(241, 29, 35, 93);

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
                    ? primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? primaryColor : primaryColor,
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
                    ? primaryColor
                    : primaryColor.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
