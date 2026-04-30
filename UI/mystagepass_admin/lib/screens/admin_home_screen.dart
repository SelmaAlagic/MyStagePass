import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mystagepass_admin/screens/reports_screen.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mystagepass_admin/screens/event_management_screen.dart';
import 'package:mystagepass_admin/screens/performer_management_screen.dart';
import 'package:mystagepass_admin/providers/auth_provider.dart';
import 'package:mystagepass_admin/providers/notification_provider.dart';
import 'package:mystagepass_admin/widgets/notification_widget.dart';
import 'package:mystagepass_admin/providers/user_provider.dart';
import 'package:mystagepass_admin/providers/event_provider.dart';
import 'package:mystagepass_admin/providers/performer_provider.dart';
import 'package:mystagepass_admin/models/User/user.dart';
import 'package:mystagepass_admin/utils/form_helpers.dart';
import 'package:mystagepass_admin/utils/image_helpers.dart';
import 'package:mystagepass_admin/utils/alert_helpers.dart';
import 'login_screen.dart';
import 'user_management_screen.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _blue = Color(0xFF2D3A8C);
const _blue50 = Color(0xFFF0F3FF);
const _blue100 = Color(0xFFE8EDFF);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _green = Color(0xFF22C55E);
const _orange = Color(0xFFFF6B35);
const _purple = Color(0xFF8B5CF6);
const _teal = Color(0xFF06B6D4);

class HomeScreen extends StatefulWidget {
  final int userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  bool _showNotifications = false;
  String _fullName = '';
  String _email = '';
  String? _profileImage;
  bool _isLoadingUserData = true;
  User? _userData;
  final UserProvider _userProvider = UserProvider();

  int _totalUsers = 0;
  int _totalEvents = 0;
  int _totalPerformers = 0;
  int _totalCustomers = 0;
  bool _loadingStats = true;

  final UserProvider _statsUserProvider = UserProvider();
  final EventProvider _statsEventProvider = EventProvider();
  final PerformerProvider _statsPerformerProvider = PerformerProvider();

  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadUserData();
    _loadNotificationCount();
    _loadStats();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final users = await _statsUserProvider.get(
        filter: {'PageSize': 1, 'Page': 0},
      );
      final customers = await _statsUserProvider.get(
        filter: {'PageSize': 1, 'Page': 0, 'Role': 'Customer'},
      );
      final events = await _statsEventProvider.get(
        filter: {'PageSize': 1, 'Page': 0},
      );
      final performers = await _statsPerformerProvider.get(
        filter: {'PageSize': 1, 'Page': 0, 'IsApproved': true},
      );

      setState(() {
        _totalUsers = users.meta?.count ?? 0;
        _totalCustomers = customers.meta?.count ?? 0;
        _totalEvents = events.meta?.count ?? 0;
        _totalPerformers = performers.meta?.count ?? 0;
        _loadingStats = false;
      });
    } catch (e) {
      setState(() => _loadingStats = false);
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _userProvider.getById(widget.userId);
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
    } catch (e) {
      debugPrint('Error loading user: $e');
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final fn = await auth.getCurrentUserFirstName();
      final ln = await auth.getCurrentUserLastName();
      final em = await auth.getCurrentUserEmail();
      setState(() {
        if (fn != null && ln != null) _fullName = '$fn $ln';
        if (em != null) _email = em;
        _isLoadingUserData = false;
      });
    }
    _animCtrl.forward();
  }

  Future<void> _loadNotificationCount() async {
    final np = Provider.of<NotificationProvider>(context, listen: false);
    await np.refreshUnreadCount();
  }

  void _toggleNotifications() =>
      setState(() => _showNotifications = !_showNotifications);

  void _showEditProfileDialog() {
    if (_userData == null) {
      _snack('Loading user data...', ok: false);
      return;
    }
    showDialog(
      context: context,
      barrierColor: Colors.black87,
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

  void _showLogoutDialog(BuildContext ctx) {
    AlertHelpers.showConfirmationAlert(
      ctx,
      'Logout',
      'Are you sure you want to logout? You will need to login again to access the admin panel.',
      confirmButtonText: 'Logout',
      cancelButtonText: 'Cancel',
      isDelete: true,
      onConfirm: () async {
        final auth = Provider.of<AuthProvider>(ctx, listen: false);
        await auth.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          ctx,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (r) => false,
        );
      },
    );
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.error_rounded,
              color: _white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: ok ? _green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  PageRouteBuilder _route(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (_, a, __, child) =>
        FadeTransition(opacity: a, child: child),
  );

  @override
  Widget build(BuildContext context) {
    final firstName = _fullName.isNotEmpty
        ? _fullName.split(' ').first
        : 'Admin';

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showEditProfileDialog,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(40),
                                border: Border.all(color: _border),
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
                                          child: _profileImage != null
                                              ? ImageHelpers.getImage(
                                                  _profileImage!,
                                                  height: 34,
                                                  width: 34,
                                                )
                                              : const CircleAvatar(
                                                  radius: 17,
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
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: _green,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _card,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 9),
                                  if (_isLoadingUserData)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _Shimmer(w: 72, h: 9),
                                        const SizedBox(height: 4),
                                        _Shimmer(w: 100, h: 8),
                                      ],
                                    )
                                  else
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _fullName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _t1,
                                          ),
                                        ),
                                        Text(
                                          _email,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _t2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 16,
                                    color: _t2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Spacer(),

                        Consumer<NotificationProvider>(
                          builder: (_, np, __) => GestureDetector(
                            onTap: _toggleNotifications,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: _showNotifications ? _blue : _card,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _showNotifications
                                            ? _blue
                                            : _border,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: _showNotifications ? _white : _t2,
                                      size: 18,
                                    ),
                                  ),
                                  if (np.unreadCount > 0)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(1),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          np.unreadCount > 99
                                              ? '99+'
                                              : '${np.unreadCount}',
                                          style: const TextStyle(
                                            color: _white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        GestureDetector(
                          onTap: () => _showLogoutDialog(context),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: _t2,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 26),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_navy, _navyMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: _navy.withOpacity(0.25),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _greeting,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isLoadingUserData ? '...' : firstName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Here's your admin overview.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _StatCard(
                                icon: Icons.people_alt_rounded,
                                label: 'Users',
                                value: _loadingStats ? '...' : '$_totalUsers',
                                color: const Color(0xFF8BA7FF),
                              ),
                              _StatCard(
                                icon: Icons.person_rounded,
                                label: 'Customers',
                                value: _loadingStats
                                    ? '...'
                                    : '$_totalCustomers',
                                color: const Color(0xFF80FFCC),
                              ),
                              _StatCard(
                                icon: Icons.mic_external_on_rounded,
                                label: 'Performers',
                                value: _loadingStats
                                    ? '...'
                                    : '$_totalPerformers',
                                color: const Color(0xFFBB9EFF),
                              ),
                              _StatCard(
                                icon: Icons.event_rounded,
                                label: 'Events',
                                value: _loadingStats ? '...' : '$_totalEvents',
                                color: const Color(0xFFFFAA80),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const _Label('MANAGEMENT'),
                    const SizedBox(height: 14),

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
                            _GridCard(
                              title: 'Manage users',
                              icon: Icons.manage_accounts_rounded,
                              color: _blue,
                              onTap: () => Navigator.push(
                                context,
                                _route(
                                  UserManagementScreen(userId: widget.userId),
                                ),
                              ).then((_) => _loadUserData()),
                            ),
                            _GridCard(
                              title: 'Manage events',
                              icon: Icons.event_available_rounded,
                              color: _orange,
                              onTap: () => Navigator.push(
                                context,
                                _route(
                                  EventManagementScreen(userId: widget.userId),
                                ),
                              ).then((_) => _loadUserData()),
                            ),
                            _GridCard(
                              title: 'Manage performers',
                              icon: Icons.interpreter_mode_rounded,
                              color: _purple,
                              onTap: () => Navigator.push(
                                context,
                                _route(
                                  PerformerManagementScreen(
                                    userId: widget.userId,
                                  ),
                                ),
                              ).then((_) => _loadUserData()),
                            ),
                            _GridCard(
                              title: 'Reports & stats',
                              icon: Icons.show_chart_rounded,
                              color: _teal,
                              onTap: () => Navigator.push(
                                context,
                                _route(ReportsScreen(userId: widget.userId)),
                              ).then((_) => _loadUserData()),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _Label('RECENT ACTIVITY'),
                        GestureDetector(
                          onTap: () => _showAllNotificationsModal(context),
                          child: const Text(
                            'View all →',
                            style: TextStyle(
                              fontSize: 12,
                              color: _blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _RecentList(),
                  ],
                ),
              ),
            ),
          ),

          if (_showNotifications)
            NotificationDropdown(
              onViewAll: () {
                setState(() => _showNotifications = false);
                _showAllNotificationsModal(context);
              },
              onClose: () => setState(() => _showNotifications = false),
            ),
        ],
      ),
    );
  }

  void _showAllNotificationsModal(BuildContext context) {
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
      setState(() {
        _notifications = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value, label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      height: 90,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _t2,
      letterSpacing: 1.3,
    ),
  );
}

class _GridCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _GridCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard> {
  bool _pressed = false;

  void _onEnter(PointerEvent _) => setState(() => _pressed = true);
  void _onExit(PointerEvent _) => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: _pressed ? widget.color : _card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pressed ? widget.color : _border,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _pressed
                    ? widget.color.withOpacity(0.25)
                    : Colors.black.withOpacity(0.07),
                blurRadius: _pressed ? 20 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _pressed
                      ? Colors.white.withOpacity(0.25)
                      : widget.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 35,
                  color: _pressed ? _white : widget.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _pressed ? _white : _t1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentList extends StatefulWidget {
  const _RecentList();

  @override
  State<_RecentList> createState() => _RecentListState();
}

class _RecentListState extends State<_RecentList> {
  final NotificationProvider _notificationProvider = NotificationProvider();
  List<dynamic> _notifications = [];
  bool _loading = true;
  int _lastUnreadCount = -1;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final np = Provider.of<NotificationProvider>(context);
    if (np.unreadCount != _lastUnreadCount) {
      _lastUnreadCount = np.unreadCount;
      _loadNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final items = await _notificationProvider.getForUser(pageSize: 4);
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
    if (_loading) {
      return Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_notifications.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: _t2, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_notifications.length, (i) {
          final item = _notifications[i];
          final isLast = i == _notifications.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: item.getNotificationColor().withOpacity(0.1),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _t1,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            item.message ?? '',
                            style: const TextStyle(fontSize: 11, color: _t2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(20),
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
              ),
              if (!isLast)
                Divider(height: 1, indent: 66, endIndent: 16, color: _border),
            ],
          );
        }),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double w, h;
  const _Shimmer({required this.w, required this.h});
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _a = CurvedAnimation(parent: _c, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, __) => Container(
      width: widget.w,
      height: widget.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color.lerp(
          const Color(0xFFE2E6F0),
          const Color(0xFFCDD3E0),
          _a.value,
        ),
      ),
    ),
  );
}

class EditProfileDialog extends StatefulWidget {
  final User user;
  final VoidCallback onSaved;
  const EditProfileDialog({Key? key, required this.user, required this.onSaved})
    : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final UserProvider _userProvider = UserProvider();

  late TextEditingController _firstNameC;
  late TextEditingController _lastNameC;
  late TextEditingController _emailC;
  late TextEditingController _usernameC;
  late TextEditingController _phoneC;
  final TextEditingController _currentPwC = TextEditingController();
  final TextEditingController _newPwC = TextEditingController();
  final TextEditingController _confirmPwC = TextEditingController();

  File? _selectedImage;
  String? _base64Image;
  bool _isLoading = false;
  bool _obscureCur = true;
  bool _obscureNew = true;
  bool _obscureCon = true;
  String? _curPwErr;
  String? _newPwErr;
  String? _conPwErr;
  bool _avatarHovered = false;
  bool _pwExpanded = false;

  bool _hasChanges = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _firstNameC = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameC = TextEditingController(text: widget.user.lastName ?? '');
    _emailC = TextEditingController(text: widget.user.email ?? '');
    _usernameC = TextEditingController(text: widget.user.username ?? '');
    _phoneC = TextEditingController(text: widget.user.phoneNumber ?? '');
    _base64Image = widget.user.image;

    for (final c in [
      _firstNameC,
      _lastNameC,
      _emailC,
      _usernameC,
      _phoneC,
      _currentPwC,
      _newPwC,
      _confirmPwC,
    ]) {
      c.addListener(_onAnyChange);
    }

    _currentPwC.addListener(() {
      if (_curPwErr != null) setState(() => _curPwErr = null);
    });
    _newPwC.addListener(() {
      if (_newPwErr != null) setState(() => _newPwErr = null);
    });
    _confirmPwC.addListener(() {
      if (_conPwErr != null) setState(() => _conPwErr = null);
    });

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
  }

  void _onAnyChange() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    for (final c in [
      _firstNameC,
      _lastNameC,
      _emailC,
      _usernameC,
      _phoneC,
      _currentPwC,
      _newPwC,
      _confirmPwC,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (img != null) {
      final f = File(img.path);
      final b = await f.readAsBytes();
      setState(() {
        _selectedImage = f;
        _base64Image = base64Encode(b);
        _hasChanges = true;
      });
    }
  }

  void _removeImage() => setState(() {
    _selectedImage = null;
    _base64Image = null;
    _hasChanges = true;
  });

  void _tryClose() {
    if (_hasChanges) {
      AlertHelpers.showConfirmationAlert(
        context,
        'Discard Changes',
        'You have unsaved changes. Are you sure you want to discard them?',
        confirmButtonText: 'Discard',
        cancelButtonText: 'Keep Editing',
        isDelete: true,
        onConfirm: () => Navigator.pop(context),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _curPwErr = null;
      _newPwErr = null;
      _conPwErr = null;
    });

    final hasNew = _newPwC.text.isNotEmpty;
    final hasCur = _currentPwC.text.isNotEmpty;
    final hasCon = _confirmPwC.text.isNotEmpty;

    if (hasCur && !hasNew) {
      setState(() {
        _newPwErr = 'Please enter new password';
        _conPwErr = 'Please enter confirmation';
        _pwExpanded = true;
      });
      return;
    }
    if (hasNew) {
      if (!hasCur) {
        setState(() {
          _curPwErr = 'Enter your current password';
          _pwExpanded = true;
        });
        return;
      }
      if (!hasCon) {
        _snack('Please confirm your new password', ok: false);
        return;
      }
      if (_newPwC.text.length < 6) {
        _snack('New password must be at least 6 characters', ok: false);
        return;
      }
      if (_newPwC.text != _confirmPwC.text) {
        _snack('Passwords do not match', ok: false);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final req = <String, dynamic>{
        'firstName': _firstNameC.text,
        'lastName': _lastNameC.text,
        'email': _emailC.text,
        'username': _usernameC.text,
        'phoneNumber': _phoneC.text.isEmpty ? null : _phoneC.text,
        'image': _base64Image,
      };
      if (hasNew) {
        req['currentPassword'] = _currentPwC.text;
        req['password'] = _newPwC.text;
        req['passwordConfirm'] = _confirmPwC.text;
      }
      await _userProvider.update(widget.user.userId!, req);
      if (!mounted) return;
      widget.onSaved();
      Navigator.pop(context);
      _snack('Profile updated successfully!', ok: true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String err = e.toString();
      if (err.contains('Exception: '))
        err = err.split('Exception: ').last.trim();
      if (err.toLowerCase().contains('password') ||
          err.toLowerCase().contains('current') ||
          err.toLowerCase().contains('confirmation')) {
        setState(() {
          _curPwErr = err;
          _pwExpanded = true;
        });
      } else {
        _snack(err, ok: false);
      }
    }
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.error_rounded,
              color: _white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: ok ? _green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight: MediaQuery.of(context).size.height - 64,
            ),
            child: Container(
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
                    _buildHeader(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 4),
                        physics: const ClampingScrollPhysics(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildAvatarRow(),
                              const SizedBox(height: 18),

                              _sectionLabel('Personal Information'),
                              const SizedBox(height: 10),

                              FormHelpers.drawFormRow(
                                children: [
                                  FormHelpers.drawModernTextField(
                                    controller: _firstNameC,
                                    label: 'First Name',
                                    icon: Icons.person_outline_rounded,
                                    required: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      if (v.length < 3)
                                        return 'Min. 3 characters';
                                      return null;
                                    },
                                  ),
                                  FormHelpers.drawModernTextField(
                                    controller: _lastNameC,
                                    label: 'Last Name',
                                    icon: Icons.person_outline_rounded,
                                    required: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      if (v.length < 3)
                                        return 'Min. 3 characters';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              FormHelpers.drawFormRow(
                                children: [
                                  FormHelpers.drawModernTextField(
                                    controller: _emailC,
                                    label: 'Email',
                                    icon: Icons.email_outlined,
                                    required: true,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                      ).hasMatch(v))
                                        return 'Invalid email';
                                      return null;
                                    },
                                  ),
                                  FormHelpers.drawModernTextField(
                                    controller: _usernameC,
                                    label: 'Username',
                                    icon: Icons.alternate_email_rounded,
                                    required: true,
                                    validator: (v) {
                                      if (v == null || v.isEmpty)
                                        return 'Required';
                                      if (v.length < 5)
                                        return 'Min. 5 characters';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Expanded(
                                    child: FormHelpers.drawModernTextField(
                                      controller: _phoneC,
                                      label: 'Phone Number',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return null;
                                        if (!RegExp(
                                          r'^\+?0?\d{8,14}$',
                                        ).hasMatch(v))
                                          return 'Invalid (8–14 digits)';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(child: SizedBox.shrink()),
                                ],
                              ),

                              const SizedBox(height: 18),
                              _buildPasswordToggle(),

                              AnimatedCrossFade(
                                firstChild: const SizedBox(
                                  width: double.infinity,
                                ),
                                secondChild: _buildPasswordFields(),
                                crossFadeState: _pwExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 260),
                                sizeCurve: Curves.easeInOut,
                              ),

                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildFooter(),
                  ],
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
              Icons.manage_accounts_rounded,
              color: _white,
              size: 17,
            ),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _white,
                  height: 1.1,
                ),
              ),
              Text(
                'Update your personal information',
                style: TextStyle(
                  fontSize: 10.5,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _tryClose,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(Icons.close_rounded, color: _white, size: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarRow() {
    final hasImage =
        _selectedImage != null ||
        (_base64Image != null && _base64Image!.isNotEmpty);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _avatarHovered = true),
            onExit: (_) => setState(() => _avatarHovered = false),
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _avatarHovered ? _blue : _blue.withOpacity(0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _blue.withOpacity(
                            _avatarHovered ? 0.20 : 0.07,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              height: 68,
                              width: 68,
                              fit: BoxFit.cover,
                            )
                          : ImageHelpers.getImage(
                              _base64Image,
                              height: 68,
                              width: 68,
                            ),
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: _avatarHovered ? 1.0 : 0.0,
                      child: ClipOval(
                        child: Container(
                          color: _navy.withOpacity(0.42),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: _white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 1,
                    right: 1,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: _white, width: 1.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _blue100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _blue.withOpacity(0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings_rounded,
                      size: 11,
                      color: _navyMid,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ADMIN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _navyMid,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap avatar to change photo',
                style: TextStyle(fontSize: 11, color: _t2),
              ),
              if (hasImage) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _removeImage,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 11,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Remove picture',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 13,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _t1,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordToggle() {
    return GestureDetector(
      onTap: () => setState(() => _pwExpanded = !_pwExpanded),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _pwExpanded ? _blue50 : _bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _pwExpanded ? _blue.withOpacity(0.25) : _border,
              width: 1.1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: _pwExpanded ? _blue.withOpacity(0.12) : _border,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: _pwExpanded ? _blue : _t2,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _pwExpanded ? _t1 : _t2,
                      ),
                    ),
                    Text(
                      _pwExpanded
                          ? 'Click to collapse'
                          : 'Click to set a new password',
                      style: const TextStyle(fontSize: 10.5, color: _t2),
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _pwExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 240),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 17,
                  color: _pwExpanded ? _blue : _t2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordFields() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: FormHelpers.drawModernTextField(
                  controller: _currentPwC,
                  label: 'Current Password',
                  icon: Icons.lock_outline_rounded,
                  isPassword: true,
                  obscureText: _obscureCur,
                  onTogglePassword: () =>
                      setState(() => _obscureCur = !_obscureCur),
                  serverError: _curPwErr,
                  validator: (v) {
                    if (_newPwC.text.isNotEmpty && (v == null || v.isEmpty))
                      return 'Enter current password';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: SizedBox.shrink()),
            ],
          ),
          const SizedBox(height: 10),
          FormHelpers.drawFormRow(
            children: [
              FormHelpers.drawModernTextField(
                controller: _newPwC,
                label: 'New Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscureNew,
                onTogglePassword: () =>
                    setState(() => _obscureNew = !_obscureNew),
                serverError: _newPwErr,
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 6)
                    return 'Min. 6 characters';
                  return null;
                },
              ),
              FormHelpers.drawModernTextField(
                controller: _confirmPwC,
                label: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                obscureText: _obscureCon,
                onTogglePassword: () =>
                    setState(() => _obscureCon = !_obscureCon),
                serverError: _conPwErr,
                validator: (v) {
                  if (_newPwC.text.isNotEmpty) {
                    if (v == null || v.isEmpty) return 'Please confirm';
                    if (v != _newPwC.text) return 'Passwords don\'t match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _tryClose,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: _border, width: 1.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                foregroundColor: _t2,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _t2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: _white,
                disabledBackgroundColor: _blue.withOpacity(0.55),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 2,
                shadowColor: _blue.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: _white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'Save Changes',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
