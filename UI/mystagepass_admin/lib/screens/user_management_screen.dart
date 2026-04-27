import 'package:flutter/material.dart';
import 'package:mystagepass_admin/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import '../models/User/user.dart';
import '../providers/user_provider.dart';
import '../utils/alert_helpers.dart';
import 'dart:async';
import 'package:mystagepass_admin/widgets/sidebar_layout.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _blue = Color(0xFF2D3A8C);
const _blue100 = Color(0xFFE8EDFF);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);

const _roleAdmin = Color(0xFF2D3A8C);
const _roleAdminBg = Color(0xFFE8EDFF);
const _rolePerformer = Color(0xFF7C3AED);
const _rolePerformerBg = Color(0xFFF3EEFF);
const _roleCustomer = Color(0xFF0891B2);
const _roleCustomerBg = Color(0xFFE0F7FA);

class UserManagementScreen extends StatefulWidget {
  final int userId;
  const UserManagementScreen({super.key, required this.userId});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool? _statusFilter;
  String? _roleFilter;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 6;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final provider = Provider.of<UserProvider>(context, listen: false);
      final params = <String, String>{
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
      };
      if (_searchQuery.isNotEmpty && _searchQuery.length >= 3) {
        params['FTS'] = _searchQuery;
      }
      if (_statusFilter != null) {
        params['IsActive'] = _statusFilter.toString();
      }
      if (_roleFilter != null) {
        params['Role'] = _roleFilter!;
      }
      final data = await provider.get(filter: params);
      if (mounted) {
        setState(() {
          _users = data.result;
          _totalPages = data.meta.totalPages;
          _totalCount = data.meta.count ?? 0;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _currentPage = page;
    _fetchUsers();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    setState(() => _searchQuery = value);
    if (value.length >= 3 || value.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 450), () {
        _currentPage = 1;
        _fetchUsers();
      });
    }
  }

  void _showDeleteConfirmation(User user) {
    final fullName = '${user.firstName} ${user.lastName}';
    AlertHelpers.showConfirmationAlert(
      context,
      'Deactivate User',
      'Are you sure you want to deactivate $fullName?',
      confirmButtonText: 'Deactivate',
      cancelButtonText: 'Cancel',
      isDelete: true,
      highlightText: fullName,
      onConfirm: () async {
        if (user.userId == null) {
          if (mounted) AlertHelpers.showError(context, 'User has no valid ID');
          return;
        }
        try {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).deactivate(user.userId!);
          if (mounted) {
            AlertHelpers.showSuccess(context, 'User successfully deactivated');
            await _fetchUsers();
          }
        } catch (e) {
          if (mounted) AlertHelpers.showError(context, 'Error: $e');
        }
      },
    );
  }

  void _showRestoreConfirmation(User user) {
    final fullName = '${user.firstName} ${user.lastName}';
    AlertHelpers.showConfirmationAlert(
      context,
      'Restore User',
      'Are you sure you want to restore $fullName?',
      confirmButtonText: 'Restore',
      cancelButtonText: 'Cancel',
      isDelete: false,
      highlightText: fullName,
      onConfirm: () async {
        try {
          await Provider.of<UserProvider>(
            context,
            listen: false,
          ).restore(user.userId!);
          if (mounted) {
            AlertHelpers.showSuccess(context, 'User successfully restored');
            await _fetchUsers();
          }
        } catch (e) {
          if (mounted) {
            AlertHelpers.showError(context, 'Error restoring user: $e');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SidebarLayout(
      userId: widget.userId,
      activeRouteKey: SidebarRoutes.users,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(),
                const SizedBox(height: 20),
                _buildMainCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'User Management',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _t1,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Manage system users and their access.',
          style: TextStyle(fontSize: 13, color: _t2),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildFilterRow(),
          _buildTable(),
          if (!_isLoading && _users.isNotEmpty) _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    final hasActiveFilters =
        _statusFilter != null || _roleFilter != null || _searchQuery.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 220,
                height: 38,
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _searchQuery.isNotEmpty && _searchQuery.length < 3
                        ? _navyMid.withOpacity(0.4)
                        : _border,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  cursorColor: _navy,
                  cursorWidth: 1.0,
                  style: const TextStyle(fontSize: 13, color: _t1),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    hintStyle: TextStyle(color: _t2, fontSize: 13),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: _t2,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: _t2,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
              if (_searchQuery.isNotEmpty && _searchQuery.length < 3)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 11,
                        color: _navyMid.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Type at least 3 characters',
                        style: TextStyle(
                          fontSize: 11,
                          color: _navyMid.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(width: 10),

          _StatusDropdown(
            value: _statusFilter,
            onChanged: (val) {
              setState(() {
                _statusFilter = val;
                _currentPage = 1;
              });
              _fetchUsers();
            },
          ),

          const SizedBox(width: 8),

          _RoleDropdown(
            value: _roleFilter,
            onChanged: (val) {
              setState(() {
                _roleFilter = val;
                _currentPage = 1;
              });
              _fetchUsers();
            },
          ),

          if (hasActiveFilters) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                setState(() {
                  _statusFilter = null;
                  _roleFilter = null;
                  _searchQuery = '';
                  _currentPage = 1;
                });
                _searchController.clear();
                _fetchUsers();
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.filter_alt_off_rounded, size: 14, color: _t2),
                      SizedBox(width: 5),
                      Text(
                        'Clear filters',
                        style: TextStyle(
                          fontSize: 12,
                          color: _t2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),

          GestureDetector(
            onTap: _showAddUserDialog,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: _navyMid,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: _white),
                    SizedBox(width: 6),
                    Text(
                      'Add Admin',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Column(
      children: [
        _buildTableHeader(),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: _navy, strokeWidth: 2),
            ),
          )
        else if (_users.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.person_search_rounded,
                  size: 36,
                  color: _t2.withOpacity(0.4),
                ),
                const SizedBox(height: 10),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No users match "$_searchQuery"'
                      : 'No users found',
                  style: const TextStyle(fontSize: 13, color: _t2),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final rowNum = ((_currentPage - 1) * _pageSize) + index + 1;
              return _buildUserRow(rowNum, _users[index], index);
            },
          ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _bg,
        border: Border(
          top: BorderSide(color: _border),
          bottom: BorderSide(color: _border),
        ),
      ),
      child: Row(
        children: [
          _th('#', width: 40),
          _th('Full Name', flex: 2),
          _th('Username', flex: 1),
          _th('Email', flex: 2),
          _th('Role', width: 110),
          _th('Status', width: 110),
          _th('Actions', width: 90),
        ],
      ),
    );
  }

  Widget _th(String label, {int? flex, double? width}) {
    final w = Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _t2,
      ),
    );
    if (flex != null) return Expanded(flex: flex, child: w);
    return SizedBox(
      width: width,
      child: Center(child: w),
    );
  }

  Widget _buildUserRow(int number, User user, int index) {
    final isEven = index % 2 == 0;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isEven ? _card : const Color(0xFFFAFBFF),
        border: const Border(bottom: BorderSide(color: _border, width: 0.5)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$number',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _t2,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _Avatar(user: user),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _t1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              user.username ?? '',
              style: const TextStyle(fontSize: 13, color: _t2),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              user.email ?? '',
              style: const TextStyle(fontSize: 13, color: _t1),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 110,
            child: Center(child: _buildRoleBadge(user.role ?? 'User')),
          ),
          SizedBox(width: 110, child: Center(child: _buildStatusBadge(user))),
          SizedBox(width: 90, child: Center(child: _buildActionButtons(user))),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color fg;
    Color bg;
    Color border;

    switch (role.toLowerCase()) {
      case 'admin':
        fg = _roleAdmin;
        bg = _roleAdminBg;
        border = _roleAdmin.withOpacity(0.25);
        break;
      case 'performer':
        fg = _rolePerformer;
        bg = _rolePerformerBg;
        border = _rolePerformer.withOpacity(0.25);
        break;
      case 'customer':
        fg = _roleCustomer;
        bg = _roleCustomerBg;
        border = _roleCustomer.withOpacity(0.25);
        break;
      default:
        fg = _t2;
        bg = _bg;
        border = _border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        role,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }

  Widget _buildStatusBadge(User user) {
    final active = user.isActive ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? _green.withOpacity(0.1) : _red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: active ? _green.withOpacity(0.3) : _red.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? _green : _red,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            active ? 'Active' : 'Inactive',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(User user) {
    final active = user.isActive ?? false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionIconBtn(
          icon: active ? Icons.block_rounded : Icons.restart_alt_rounded,
          color: active ? _red : _green,
          onTap: active
              ? () => _showDeleteConfirmation(user)
              : () => _showRestoreConfirmation(user),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final from = ((_currentPage - 1) * _pageSize) + 1;
    final to = ((_currentPage - 1) * _pageSize) + _users.length;

    int startPage = (_currentPage - 2).clamp(1, _totalPages);
    int endPage = (startPage + 4).clamp(1, _totalPages);
    if (endPage - startPage < 4) {
      startPage = (endPage - 4).clamp(1, _totalPages);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Row(
        children: [
          Text(
            'Showing $from to $to of $_totalCount users',
            style: const TextStyle(fontSize: 12, color: _t2),
          ),
          const Spacer(),
          Row(
            children: [
              _PagArrow(
                icon: Icons.chevron_left_rounded,
                enabled: _hasPrevious,
                onTap: () => _goToPage(_currentPage - 1),
              ),
              const SizedBox(width: 4),
              ...List.generate(endPage - startPage + 1, (i) {
                final page = startPage + i;
                final isActive = page == _currentPage;
                return GestureDetector(
                  onTap: () => _goToPage(page),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isActive ? _navyMid : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive ? _navyMid : _border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$page',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive ? _white : _t1,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 4),
              _PagArrow(
                icon: Icons.chevron_right_rounded,
                enabled: _hasNext,
                onTap: () => _goToPage(_currentPage + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    final formKey = GlobalKey<FormState>();
    final firstNameC = TextEditingController();
    final lastNameC = TextEditingController();
    final emailC = TextEditingController();
    final usernameC = TextEditingController();
    final passwordC = TextEditingController();
    final confirmPasswordC = TextEditingController();

    bool obscurePassword = true;
    bool obscureConfirmPassword = true;
    bool isSubmitting = false;

    String? firstNameError;
    String? lastNameError;
    String? emailError;
    String? usernameError;
    String? passwordError;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            InputDecoration fieldDecor({
              required String label,
              required IconData icon,
              String? error,
              Widget? suffix,
            }) {
              return InputDecoration(
                labelText: label,
                labelStyle: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
                prefixIcon: Icon(icon, size: 18, color: _navyMid),
                suffixIcon: suffix,
                isDense: true,
                filled: true,
                fillColor: _bg,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 14,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: error != null ? _red : _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: error != null ? _red : _blue,
                    width: 1.2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _red, width: 1.2),
                ),
                errorText: error,
                errorStyle: const TextStyle(color: _red, fontSize: 11),
              );
            }

            return Dialog(
              backgroundColor: _white,
              surfaceTintColor: _white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 540),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_navy, _navyMid],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
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
                              Icons.person_add_rounded,
                              color: _white,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add New Admin',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _white,
                                ),
                              ),
                              Text(
                                'Fill in all fields to create an admin account',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
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
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _dialogSectionLabel('Personal Information'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: firstNameC,
                                      cursorColor: _navy,
                                      cursorWidth: 1.0,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _t1,
                                      ),
                                      decoration: fieldDecor(
                                        label: 'First Name',
                                        icon: Icons.person_outline,
                                        error: firstNameError,
                                      ),
                                      onChanged: (_) {
                                        if (firstNameError != null) {
                                          setDialogState(
                                            () => firstNameError = null,
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v!.isEmpty) return 'Required';
                                        if (v.length < 3) {
                                          return 'Min. 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: lastNameC,
                                      cursorColor: _navy,
                                      cursorWidth: 1.0,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _t1,
                                      ),
                                      decoration: fieldDecor(
                                        label: 'Last Name',
                                        icon: Icons.person_outline,
                                        error: lastNameError,
                                      ),
                                      onChanged: (_) {
                                        if (lastNameError != null) {
                                          setDialogState(
                                            () => lastNameError = null,
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v!.isEmpty) return 'Required';
                                        if (v.length < 3) {
                                          return 'Min. 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: emailC,
                                      cursorColor: _navy,
                                      cursorWidth: 1.0,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _t1,
                                      ),
                                      decoration: fieldDecor(
                                        label: 'Email Address',
                                        icon: Icons.email_outlined,
                                        error: emailError,
                                      ),
                                      onChanged: (_) {
                                        if (emailError != null) {
                                          setDialogState(
                                            () => emailError = null,
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v!.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!RegExp(
                                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                        ).hasMatch(v)) {
                                          return 'Invalid email format';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: usernameC,
                                      cursorColor: _navy,
                                      cursorWidth: 1.0,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _t1,
                                      ),
                                      decoration: fieldDecor(
                                        label: 'Username',
                                        icon: Icons.alternate_email,
                                        error: usernameError,
                                      ),
                                      onChanged: (_) {
                                        if (usernameError != null) {
                                          setDialogState(
                                            () => usernameError = null,
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Required';
                                        }
                                        if (v.length < 5) {
                                          return 'Min. 5 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(height: 1, color: _border),
                              const SizedBox(height: 14),
                              _dialogSectionLabel('Password'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: passwordC,
                                      obscureText: obscurePassword,
                                      cursorColor: _navy,
                                      cursorWidth: 1.0,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _t1,
                                      ),
                                      decoration: fieldDecor(
                                        label: 'Password',
                                        icon: Icons.lock_outline,
                                        error: passwordError,
                                        suffix: IconButton(
                                          icon: Icon(
                                            obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            size: 17,
                                            color: _t2,
                                          ),
                                          onPressed: () => setDialogState(
                                            () => obscurePassword =
                                                !obscurePassword,
                                          ),
                                        ),
                                      ),
                                      onChanged: (_) {
                                        if (passwordError != null) {
                                          setDialogState(
                                            () => passwordError = null,
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v == null || v.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (v.length < 6) {
                                          return 'Minimum 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: confirmPasswordC,
                                      obscureText: obscureConfirmPassword,
                                      cursorColor: _navy,
                                      cursorWidth: 1.0,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _t1,
                                      ),
                                      decoration: fieldDecor(
                                        label: 'Confirm Password',
                                        icon: Icons.lock_outline,
                                        error: passwordError,
                                        suffix: IconButton(
                                          icon: Icon(
                                            obscureConfirmPassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            size: 17,
                                            color: _t2,
                                          ),
                                          onPressed: () => setDialogState(
                                            () => obscureConfirmPassword =
                                                !obscureConfirmPassword,
                                          ),
                                        ),
                                      ),
                                      onChanged: (_) {
                                        if (passwordError != null) {
                                          setDialogState(
                                            () => passwordError = null,
                                          );
                                        }
                                      },
                                      validator: (v) {
                                        if (v!.isEmpty) {
                                          return 'Please confirm password';
                                        }
                                        if (v != passwordC.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                      decoration: const BoxDecoration(
                        color: _bg,
                        border: Border(top: BorderSide(color: _border)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                side: const BorderSide(
                                  color: _border,
                                  width: 1.2,
                                ),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) {
                                        return;
                                      }
                                      setDialogState(() => isSubmitting = true);
                                      final newUser = {
                                        'firstName': firstNameC.text,
                                        'lastName': lastNameC.text,
                                        'email': emailC.text,
                                        'username': usernameC.text,
                                        'password': passwordC.text,
                                        'passwordConfirm':
                                            confirmPasswordC.text,
                                        'role': 'Admin',
                                        'isActive': true,
                                      };
                                      try {
                                        final provider =
                                            Provider.of<AdminProvider>(
                                              context,
                                              listen: false,
                                            );
                                        await provider.insert(newUser);
                                        if (mounted) {
                                          Navigator.pop(context);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                'Admin successfully added',
                                              ),
                                              backgroundColor: _green,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              margin: const EdgeInsets.all(16),
                                            ),
                                          );
                                          _currentPage = 1;
                                          _fetchUsers();
                                        }
                                      } catch (e) {
                                        setDialogState(
                                          () => isSubmitting = false,
                                        );
                                        if (!mounted) return;
                                        String msg = e
                                            .toString()
                                            .replaceFirst('Exception: ', '')
                                            .trim();
                                        final lower = msg.toLowerCase();
                                        if (lower.contains('first')) {
                                          setDialogState(
                                            () => firstNameError = msg,
                                          );
                                        } else if (lower.contains('last')) {
                                          setDialogState(
                                            () => lastNameError = msg,
                                          );
                                        } else if (lower.contains('email')) {
                                          setDialogState(
                                            () => emailError = msg,
                                          );
                                        } else if (lower.contains('username')) {
                                          setDialogState(
                                            () => usernameError = msg,
                                          );
                                        } else if (lower.contains('password') ||
                                            lower.contains('confirm')) {
                                          setDialogState(
                                            () => passwordError = msg,
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Error: $msg'),
                                              backgroundColor: _red,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              margin: const EdgeInsets.all(16),
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _navy,
                                foregroundColor: _white,
                                disabledBackgroundColor: _navy.withOpacity(0.5),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: _white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Add Admin',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogSectionLabel(String text) {
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
}

class _StatusDropdown extends StatefulWidget {
  final bool? value;
  final void Function(bool?) onChanged;

  const _StatusDropdown({required this.value, required this.onChanged});

  @override
  State<_StatusDropdown> createState() => _StatusDropdownState();
}

class _StatusDropdownState extends State<_StatusDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: _SimpleDropdownMenu<bool?>(
                  options: const [
                    _SimpleOption(
                      label: 'All Statuses',
                      value: null,
                      icon: null,
                      color: null,
                    ),
                    _SimpleOption(
                      label: 'Active',
                      value: true,
                      icon: Icons.circle,
                      color: Color(0xFF22C55E),
                    ),
                    _SimpleOption(
                      label: 'Inactive',
                      value: false,
                      icon: Icons.circle,
                      color: Color(0xFFEF4444),
                    ),
                  ],
                  selectedValue: widget.value,
                  onSelect: (val) {
                    _close();
                    widget.onChanged(val);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.value != null;
    final label = widget.value == null
        ? 'Status'
        : widget.value == true
        ? 'Active'
        : 'Inactive';
    final dotColor = widget.value == null
        ? null
        : widget.value == true
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isOpen || isActive
                  ? const Color(0xFFE8EDFF)
                  : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen || isActive
                    ? const Color(0xFF2D3A8C).withOpacity(0.4)
                    : const Color(0xFFECEFF8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dotColor != null) ...[
                  Icon(Icons.circle, size: 8, color: dotColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isOpen || isActive
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF1E2642),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _isOpen || isActive
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF8A93B2),
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

class _RoleDropdown extends StatefulWidget {
  final String? value;
  final void Function(String?) onChanged;

  const _RoleDropdown({required this.value, required this.onChanged});

  @override
  State<_RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<_RoleDropdown> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _toggle() => _isOpen ? _close() : _open();

  void _open() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _isOpen = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _isOpen = false);
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (ctx) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _close,
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            CompositedTransformFollower(
              link: _layerLink,
              offset: const Offset(0, 42),
              child: Material(
                color: Colors.transparent,
                child: _SimpleDropdownMenu<String?>(
                  options: const [
                    _SimpleOption(
                      label: 'All Roles',
                      value: null,
                      icon: null,
                      color: null,
                    ),
                    _SimpleOption(
                      label: 'Admin',
                      value: 'Admin',
                      icon: Icons.admin_panel_settings_rounded,
                      color: Color(0xFF2D3A8C),
                    ),
                    _SimpleOption(
                      label: 'Customer',
                      value: 'Customer',
                      icon: Icons.person_rounded,
                      color: Color(0xFF0891B2),
                    ),
                    _SimpleOption(
                      label: 'Performer',
                      value: 'Performer',
                      icon: Icons.mic_rounded,
                      color: Color(0xFF7C3AED),
                    ),
                  ],
                  selectedValue: widget.value,
                  onSelect: (val) {
                    _close();
                    widget.onChanged(val);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  IconData? get _selectedIcon => switch (widget.value) {
    'Admin' => Icons.admin_panel_settings_rounded,
    'Customer' => Icons.person_rounded,
    'Performer' => Icons.mic_rounded,
    _ => null,
  };

  Color? get _selectedColor => switch (widget.value) {
    'Admin' => const Color(0xFF2D3A8C),
    'Customer' => const Color(0xFF0891B2),
    'Performer' => const Color(0xFF7C3AED),
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final isActive = widget.value != null;
    final label = widget.value ?? 'Role';

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggle,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isOpen || isActive
                  ? const Color(0xFFE8EDFF)
                  : const Color(0xFFF4F6FB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isOpen || isActive
                    ? const Color(0xFF2D3A8C).withOpacity(0.4)
                    : const Color(0xFFECEFF8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selectedIcon != null) ...[
                  Icon(_selectedIcon, size: 13, color: _selectedColor),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isOpen || isActive
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF1E2642),
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _isOpen || isActive
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF8A93B2),
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

class _SimpleOption<T> {
  final String label;
  final T value;
  final IconData? icon;
  final Color? color;

  const _SimpleOption({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _SimpleDropdownMenu<T> extends StatelessWidget {
  final List<_SimpleOption<T>> options;
  final T selectedValue;
  final void Function(T) onSelect;

  const _SimpleDropdownMenu({
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECEFF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected = opt.value == selectedValue;
            return _SimpleDropdownItem(
              label: opt.label,
              icon: opt.icon,
              color: opt.color,
              isSelected: isSelected,
              onTap: () => onSelect(opt.value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SimpleDropdownItem extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SimpleDropdownItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SimpleDropdownItem> createState() => _SimpleDropdownItemState();
}

class _SimpleDropdownItemState extends State<_SimpleDropdownItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    if (widget.isSelected) {
      bg = const Color(0xFFE8EDFF);
    } else if (_hovered) {
      bg = const Color(0xFFF4F6FB);
    } else {
      bg = Colors.transparent;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 12, color: widget.color),
                const SizedBox(width: 8),
              ] else
                const SizedBox(width: 20),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isSelected
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? const Color(0xFF2D3A8C)
                        : const Color(0xFF1E2642),
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Color(0xFF2D3A8C),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final User user;
  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = [
      (user.firstName ?? '').isNotEmpty ? user.firstName![0] : '',
      (user.lastName ?? '').isNotEmpty ? user.lastName![0] : '',
    ].join();

    final colors = [
      [const Color(0xFF3B82F6), const Color(0xFFEFF6FF)],
      [const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)],
      [const Color(0xFF06B6D4), const Color(0xFFECFEFF)],
      [const Color(0xFF22C55E), const Color(0xFFF0FDF4)],
      [const Color(0xFFFF6B35), const Color(0xFFFFF7ED)],
    ];
    final idx = (user.userId ?? 0) % colors.length;
    final fg = colors[idx][0];
    final bg = colors[idx][1];

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: fg.withOpacity(0.25), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _ActionIconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionIconBtn> createState() => _ActionIconBtnState();
}

class _ActionIconBtnState extends State<_ActionIconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered ? widget.color.withOpacity(0.08) : _white,
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered ? widget.color.withOpacity(0.25) : _border,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered ? widget.color : widget.color.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _PagArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PagArrow({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _border),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? _t1 : _t2.withOpacity(0.35),
          ),
        ),
      ),
    );
  }
}
