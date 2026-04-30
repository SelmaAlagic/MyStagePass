import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mystagepass_admin/providers/auth_provider.dart';
import 'package:mystagepass_admin/providers/notification_provider.dart';
import 'package:mystagepass_admin/providers/user_provider.dart';
import 'package:mystagepass_admin/utils/image_helpers.dart';
import 'package:mystagepass_admin/widgets/notification_widget.dart';
import 'package:mystagepass_admin/screens/login_screen.dart';
import 'package:mystagepass_admin/utils/alert_helpers.dart';
import 'package:mystagepass_admin/models/User/user.dart';
import 'package:mystagepass_admin/screens/admin_home_screen.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _blue100 = Color(0xFFE8EDFF);
const _red = Color(0xFFEF4444);
const _green = Color(0xFF22C55E);
const _card = Color(0xFFFFFFFF);
const _blue = Color(0xFF2D3A8C);

class SidebarRoutes {
  static const users = 'users';
  static const events = 'events';
  static const performers = 'performers';
  static const reports = 'reports';
}

class SidebarLayout extends StatefulWidget {
  final int userId;
  final String activeRouteKey;
  final Widget child;

  const SidebarLayout({
    super.key,
    required this.userId,
    required this.activeRouteKey,
    required this.child,
  });

  static final Map<String, Widget Function(int userId)> _builders = {};

  static void registerScreen(
    String routeKey,
    Widget Function(int userId) builder,
  ) => _builders[routeKey] = builder;

  @override
  State<SidebarLayout> createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  bool _showNotifications = false;
  String _fullName = '';
  String _email = '';
  String? _profileImage;
  bool _isLoadingUserData = true;
  User? _userData;
  final UserProvider _userProvider = UserProvider();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadNotificationCount();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userProvider.getById(widget.userId);
      if (mounted) {
        setState(() {
          _userData = user;
          _profileImage = user.image;
          final fn = user.firstName ?? '';
          final ln = user.lastName ?? '';
          if (fn.isNotEmpty || ln.isNotEmpty) _fullName = '$fn $ln'.trim();
          if (user.email != null && user.email!.isNotEmpty) {
            _email = user.email!;
          }
          _isLoadingUserData = false;
        });
      }
    } catch (e) {
      debugPrint('SidebarLayout _loadUserData: $e');
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final fn = await auth.getCurrentUserFirstName();
      final ln = await auth.getCurrentUserLastName();
      final em = await auth.getCurrentUserEmail();
      if (mounted) {
        setState(() {
          if (fn != null && ln != null) _fullName = '$fn $ln';
          if (em != null) _email = em;
          _isLoadingUserData = false;
        });
      }
    }
  }

  Future<void> _loadNotificationCount() async {
    await Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).refreshUnreadCount();
  }

  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: child),
  );

  void _goToDashboard() =>
      Navigator.of(context).popUntil((route) => route.isFirst);

  void _navigateTo(String routeKey) {
    if (routeKey == widget.activeRouteKey) return;
    final builder = SidebarLayout._builders[routeKey];
    if (builder == null) return;
    Navigator.of(context).pushReplacement(_fade(builder(widget.userId)));
  }

  void _showLogoutDialog() {
    AlertHelpers.showConfirmationAlert(
      context,
      'Logout',
      'Are you sure you want to logout? You will need to login again to access the admin panel.',
      confirmButtonText: 'Logout',
      cancelButtonText: 'Cancel',
      isDelete: true,
      onConfirm: () async {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      },
    );
  }

  void _showEditProfileDialog() {
    if (_userData == null) return;
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: false,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: EditProfileDialog(user: _userData!, onSaved: _loadUserData),
          ),
        ),
      ),
    );
  }

  void _showAllNotificationsModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
      builder: (_) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: AllNotificationsModal(onClose: () => Navigator.pop(context)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Sidebar(
                activeRouteKey: widget.activeRouteKey,
                onDashboard: _goToDashboard,
                onNavigate: _navigateTo,
                onLogout: _showLogoutDialog,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopBar(
                      fullName: _fullName,
                      email: _email,
                      profileImage: _profileImage,
                      isLoading: _isLoadingUserData,
                      activeRouteKey: widget.activeRouteKey,
                      onNotificationTap: () => setState(
                        () => _showNotifications = !_showNotifications,
                      ),
                      onProfileTap: _showEditProfileDialog,
                    ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),

          if (_showNotifications)
            NotificationDropdown(
              onViewAll: () {
                setState(() => _showNotifications = false);
                _showAllNotificationsModal();
              },
              onClose: () => setState(() => _showNotifications = false),
            ),
        ],
      ),
    );
  }
}

class AllNotificationsModal extends StatefulWidget {
  final VoidCallback onClose;
  const AllNotificationsModal({super.key, required this.onClose});

  @override
  State<AllNotificationsModal> createState() => _AllNotificationsModalState();
}

class _AllNotificationsModalState extends State<AllNotificationsModal>
    with SingleTickerProviderStateMixin {
  final NotificationProvider _notificationProvider = NotificationProvider();
  List<dynamic> _notifications = [];
  bool _loading = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
    _loadNotifications();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final items = await _notificationProvider.getForUser(pageSize: 100);
      items.sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
      if (mounted) {
        setState(() {
          _notifications = items;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 80,
          ),
          decoration: BoxDecoration(
            color: _white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _navy.withOpacity(0.14),
                blurRadius: 40,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_navy, _navyMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: _white,
                          size: 17,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'All Notifications',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _white,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            _loading
                                ? 'Loading...'
                                : '${_notifications.length} total',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: widget.onClose,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: _white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: _loading
                      ? const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(color: _blue),
                          ),
                        )
                      : _notifications.isEmpty
                      ? SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: _blue.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.notifications_off_outlined,
                                    size: 32,
                                    color: _blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _t1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "You're all caught up!",
                                  style: TextStyle(fontSize: 12, color: _t2),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: _notifications.length,
                          separatorBuilder: (_, i) => Divider(
                            height: 1,
                            indent: 66,
                            endIndent: 16,
                            color: _border,
                          ),
                          itemBuilder: (context, i) {
                            final item = _notifications[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: item
                                          .getNotificationColor()
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: Icon(
                                      item.getNotificationIcon(),
                                      size: 17,
                                      color: item.getNotificationColor(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.title ?? '',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: _t1,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: _bg,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                item.getTimeAgo(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: _t2,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.message ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: _t2,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final String activeRouteKey;
  final VoidCallback onDashboard;
  final void Function(String key) onNavigate;
  final VoidCallback onLogout;

  const _Sidebar({
    required this.activeRouteKey,
    required this.onDashboard,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 218,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: _white,
        border: Border(right: BorderSide(color: _border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 78,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _border)),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: _navy,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: _white,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Admin Panel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _t1,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NavItem(
                    icon: Icons.home_rounded,
                    label: 'Dashboard',
                    isActive: false,
                    onTap: onDashboard,
                  ),
                  const SizedBox(height: 2),
                  _NavItem(
                    icon: Icons.manage_accounts_rounded,
                    label: 'Users',
                    isActive: activeRouteKey == SidebarRoutes.users,
                    onTap: () => onNavigate(SidebarRoutes.users),
                  ),
                  const SizedBox(height: 2),
                  _NavItem(
                    icon: Icons.event_available_rounded,
                    label: 'Events',
                    isActive: activeRouteKey == SidebarRoutes.events,
                    onTap: () => onNavigate(SidebarRoutes.events),
                  ),
                  const SizedBox(height: 2),
                  _NavItem(
                    icon: Icons.interpreter_mode_rounded,
                    label: 'Performers',
                    isActive: activeRouteKey == SidebarRoutes.performers,
                    onTap: () => onNavigate(SidebarRoutes.performers),
                  ),
                  const SizedBox(height: 2),
                  _NavItem(
                    icon: Icons.show_chart_rounded,
                    label: 'Reports & Stats',
                    isActive: activeRouteKey == SidebarRoutes.reports,
                    onTap: () => onNavigate(SidebarRoutes.reports),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _border)),
            ),
            child: _NavItem(
              icon: Icons.logout_rounded,
              label: 'Log out',
              isActive: false,
              isLogout: true,
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isLogout;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color iconColor;
    final Color textColor;

    if (widget.isLogout) {
      bg = _hovered ? _red.withOpacity(0.07) : Colors.transparent;
      iconColor = _hovered ? _red : _t2;
      textColor = _hovered ? _red : _t2;
    } else if (widget.isActive) {
      bg = _navy;
      iconColor = _white;
      textColor = _white;
    } else {
      bg = _hovered ? _bg : Colors.transparent;
      iconColor = _hovered ? _t1 : _t2;
      textColor = _hovered ? _t1 : _t2;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 17, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isActive
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String fullName;
  final String email;
  final String? profileImage;
  final bool isLoading;
  final String activeRouteKey;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const _TopBar({
    required this.fullName,
    required this.email,
    required this.profileImage,
    required this.isLoading,
    required this.activeRouteKey,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  String get _title => switch (activeRouteKey) {
    SidebarRoutes.users => 'User Management',
    SidebarRoutes.events => 'Event Management',
    SidebarRoutes.performers => 'Performer Management',
    SidebarRoutes.reports => 'Reports & Stats',
    _ => 'Dashboard',
  };

  String get _subtitle => switch (activeRouteKey) {
    SidebarRoutes.users => 'Manage system users and their access.',
    SidebarRoutes.events => 'Manage events and bookings.',
    SidebarRoutes.performers => 'Manage performer profiles.',
    SidebarRoutes.reports => 'View analytics and statistics.',
    _ => 'Welcome back.',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(color: _bg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Consumer<NotificationProvider>(
            builder: (_, np, __) => GestureDetector(
              onTap: onNotificationTap,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _card,
                        shape: BoxShape.circle,
                        border: Border.all(color: _border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: _navy,
                        size: 18,
                      ),
                    ),
                    if (np.unreadCount > 0)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 17),
                          height: 17,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: _red,
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: _white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              np.unreadCount > 9 ? '9+' : '${np.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          GestureDetector(
            onTap: onProfileTap,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: _AdminChip(
                fullName: fullName,
                email: email,
                profileImage: profileImage,
                isLoading: isLoading,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminChip extends StatefulWidget {
  final String fullName;
  final String email;
  final String? profileImage;
  final bool isLoading;

  const _AdminChip({
    required this.fullName,
    required this.email,
    required this.profileImage,
    required this.isLoading,
  });

  @override
  State<_AdminChip> createState() => _AdminChipState();
}

class _AdminChipState extends State<_AdminChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _hovered ? const Color(0xFFF0F3FF) : _card,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: _hovered ? _blue.withOpacity(0.3) : _border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _blue.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: widget.profileImage != null
                        ? ImageHelpers.getImage(
                            widget.profileImage!,
                            height: 32,
                            width: 32,
                          )
                        : const CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(
                              'assets/images/NoProfileImage.png',
                            ),
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: _green,
                      shape: BoxShape.circle,
                      border: Border.all(color: _card, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 9),
            if (widget.isLoading)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _shimmer(w: 72, h: 9),
                  const SizedBox(height: 4),
                  _shimmer(w: 100, h: 8),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.fullName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _t1,
                    ),
                  ),
                  Text(
                    widget.email,
                    style: const TextStyle(fontSize: 11, color: _t2),
                  ),
                ],
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: _hovered ? _blue : _t2,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _shimmer({required double w, required double h}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: _border,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
