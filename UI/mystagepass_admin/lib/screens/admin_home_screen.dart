import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                  vertical: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage(
                            'assets/images/NoProfileImage.png',
                          ),
                        ),
                        const SizedBox(width: 20),
                        _customLogoutButton(
                          onTap: () => _showLogoutDialog(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 1),
              const Text(
                "Welcome back, Admin!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: 450,
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.3,
                    children: [
                      _buildImageCard(
                        0,
                        "Manage users",
                        'assets/svg/usersIcon.svg',
                        () {},
                      ),
                      _buildImageCard(
                        1,
                        "Manage events",
                        'assets/svg/eventsIcon.svg',
                        () {},
                      ),
                      _buildImageCard(
                        2,
                        "Manage performers",
                        'assets/svg/performersIcon.svg',
                        () {},
                      ),
                      _buildImageCard(
                        3,
                        "Reports and stats",
                        'assets/svg/reportsIcon.svg',
                        () {},
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(
    int index,
    String title,
    String svgPath,
    VoidCallback onTap,
  ) {
    bool isHovered = _hoveredIndex == index;
    double currentImageSize = (title == "Manage performers") ? 95 : 85;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hoveredIndex = index),
      onExit: (_) => setState(() => _hoveredIndex = null),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F7),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isHovered
                  ? const Color.fromARGB(255, 151, 200, 240)
                  : Colors.transparent,
              width: 2,
            ),
            boxShadow: isHovered
                ? [
                    const BoxShadow(
                      color: Color.fromARGB(255, 220, 234, 245),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                      spreadRadius: 1,
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Colors.black,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgPath,
                height: currentImageSize,
                width: currentImageSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1D2939),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _customLogoutButton({required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Icon(Icons.logout_rounded, size: 18, color: Colors.red),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Are you sure you want to logout?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: _modernButton(
                            label: "Cancel",
                            color: Colors.blue,
                            onTap: () => Navigator.pop(dialogContext),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _modernButton(
                            label: "Logout",
                            color: Colors.red,
                            onTap: () {
                              Navigator.pop(dialogContext);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _modernButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    bool isHovering = false;
    return StatefulBuilder(
      builder: (context, setLocalState) {
        return MouseRegion(
          onEnter: (_) => setLocalState(() => isHovering = true),
          onExit: (_) => setLocalState(() => isHovering = false),
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isHovering ? color : Colors.white,
              foregroundColor: isHovering ? Colors.white : color,
              elevation: 0,
              side: BorderSide(color: color, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
