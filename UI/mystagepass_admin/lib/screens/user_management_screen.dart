import 'package:flutter/material.dart';
import 'package:mystagepass_admin/providers/admin_provider.dart';
import 'package:provider/provider.dart';
import '../models/User/user.dart';
import '../providers/user_provider.dart';
import 'dart:async';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> _users = [];
  bool _isLoading = false;
  String _searchQuery = "";
  bool? _statusFilter;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasPrevious = false;
  bool _hasNext = false;
  final int _pageSize = 5;

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
    _isLoading = true;
    try {
      var provider = Provider.of<UserProvider>(context, listen: false);
      var params = {
        'Page': (_currentPage - 1).toString(),
        'PageSize': _pageSize.toString(),
      };

      if (_searchQuery.isNotEmpty && _searchQuery.length >= 3) {
        params['FTS'] = _searchQuery;
      }
      if (_statusFilter != null) {
        params['IsActive'] = _statusFilter.toString();
      }

      var data = await provider.get(filter: params);

      if (mounted) {
        setState(() {
          _users = data.result;
          _totalPages = data.meta.totalPages;
          _currentPage = data.meta.currentPage + 1;
          _hasPrevious = data.meta.hasPrevious;
          _hasNext = data.meta.hasNext;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Center(
            child: Text(
              "Deletion Confirmation",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: Colors.black),
              children: [
                const TextSpan(text: "Are you sure you want to delete user "),
                TextSpan(
                  text: "${user.firstName} ${user.lastName}",
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: "?"),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  onHover: (isHovering) {},
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                  ),
                  onPressed: () async {
                    final provider = Provider.of<UserProvider>(
                      context,
                      listen: false,
                    );

                    Navigator.pop(context);

                    if (user.userId == null) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User does not have a valid ID"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                      return;
                    }

                    try {
                      await provider.deactivate(user.userId!);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("User successfully deactivated"),
                            backgroundColor: Colors.green,
                          ),
                        );

                        if (_statusFilter == true) {
                          setState(() {
                            _users.removeWhere((u) => u.userId == user.userId);
                          });
                        } else if (_statusFilter == null) {
                          setState(() {
                            int index = _users.indexWhere(
                              (u) => u.userId == user.userId,
                            );
                            if (index != -1) {
                              _users[index] = User(
                                userId: user.userId,
                                firstName: user.firstName,
                                lastName: user.lastName,
                                email: user.email,
                                role: user.role,
                                isActive: false,
                              );
                            }
                          });
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9DB4FF),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(),
              _buildBackButton(),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              _buildFilters(),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 900),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTableHeader(),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        int rowNumber =
                            ((_currentPage - 1) * _pageSize) + index + 1;
                        return _buildUserRow(rowNumber, _users[index]);
                      },
                    ),
                    if (_users.isEmpty && !_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text(
                          "No users found",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (_users.isNotEmpty) _buildPagination(),
              const SizedBox(height: 20),
              _buildAddNewUserButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "User Management",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A237E),
            ),
          ),
          const Icon(
            Icons.account_circle_outlined,
            size: 32,
            color: Color(0xFF1A237E),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 220,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              cursorColor: const Color(0xFF1A237E),
              cursorWidth: 1.0,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 13, color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                prefixIcon: Icon(Icons.search, size: 16, color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(hoverColor: const Color(0xFFE3F2FD)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _statusFilter == null
                      ? "All"
                      : (_statusFilter == true ? "Active" : "Inactive"),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: ["All", "Active", "Inactive"]
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(
                            v,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _onStatusFilterChanged,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF5865F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _tableHeaderCell('#', width: 40),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Full Name', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Username', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Email', flex: 2),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Role', width: 80),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Status', width: 90),
            _verticalDivider(Colors.white30),
            _tableHeaderCell('Actions', width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRow(int number, User user) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          _tableCell(number.toString(), width: 40, isBold: true, center: true),
          _verticalDivider(Colors.grey.shade300),
          _tableCell("${user.firstName} ${user.lastName}", flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(user.username ?? "", flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(user.email ?? "", flex: 2),
          _verticalDivider(Colors.grey.shade300),
          _tableCell(user.role ?? "User", width: 80, center: true),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(width: 90, child: Center(child: _buildStatusBadge(user))),
          _verticalDivider(Colors.grey.shade300),
          SizedBox(width: 100, child: Center(child: _buildActionButtons(user))),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(User user) {
    final bool active = user.isActive ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: active ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: active ? Colors.green : Colors.red,
          width: 0.5,
        ),
      ),
      child: Text(
        active ? "Active" : "Inactive",
        style: TextStyle(
          color: active ? Colors.green[800] : Colors.red[800],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(User user) {
    if (user.isActive ?? false) {
      return _actionIcon(
        Icons.delete,
        const Color(0xFFE53935),
        const Color(0xFFFFEBEE),
        onTap: () => _showDeleteConfirmation(user),
        width: 80,
        height: 36,
        label: "Delete",
      );
    } else {
      return _actionIcon(
        Icons.restore,
        Colors.green[800]!,
        const Color(0xFFE8F5E9),
        onTap: () async {
          final provider = Provider.of<UserProvider>(context, listen: false);
          try {
            await provider.restore(user.userId!);

            if (mounted) {
              setState(() {
                int index = _users.indexWhere((u) => u.userId == user.userId);
                if (index != -1) {
                  _users[index] = User(
                    userId: user.userId,
                    firstName: user.firstName,
                    lastName: user.lastName,
                    email: user.email,
                    role: user.role,
                    isActive: true,
                  );
                }
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User successfully activated"),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error activating user: $e"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        width: double.infinity,
        height: 36,
        label: "Activate",
      );
    }
  }

  Widget _actionIcon(
    IconData icon,
    Color iconColor,
    Color bg, {
    VoidCallback? onTap,
    double? width,
    double? height,
    String? label,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: width ?? 26,
        height: height ?? 26,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 16),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: iconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text, {int? flex, double? width}) {
    Widget content = Center(
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
    return flex != null
        ? Expanded(flex: flex, child: content)
        : SizedBox(width: width, child: content);
  }

  Widget _tableCell(
    String text, {
    int? flex,
    double? width,
    bool isBold = false,
    bool center = false,
  }) {
    return Container(
      width: width,
      child: flex != null
          ? Expanded(flex: flex, child: _cellText(text, isBold, center))
          : _cellText(text, isBold, center),
    );
  }

  Widget _cellText(String text, bool isBold, bool center) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: center ? Alignment.center : Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _verticalDivider(Color color) =>
      VerticalDivider(color: color, thickness: 1, indent: 6, endIndent: 6);

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _hasPrevious ? _goToPreviousPage : null,
          icon: Icon(
            Icons.chevron_left,
            color: _hasPrevious ? Colors.white : Colors.white38,
          ),
        ),
        Text(
          "$_currentPage of $_totalPages",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: _hasNext ? _goToNextPage : null,
          icon: Icon(
            Icons.chevron_right,
            color: _hasNext ? Colors.white : Colors.white38,
          ),
        ),
      ],
    );
  }

  Widget _buildAddNewUserButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      alignment: Alignment.centerRight,
      child: ElevatedButton.icon(
        onPressed: _showAddUserDialog,
        icon: const Icon(Icons.person_add_alt_1, size: 20, color: Colors.white),
        label: const Text(
          "Add New User",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5865F2),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final _formKey = GlobalKey<FormState>();
    final _firstNameController = TextEditingController();
    final _lastNameController = TextEditingController();
    final _emailController = TextEditingController();
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();

    bool _obscurePassword = true;
    bool _isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: [
                  const Icon(
                    Icons.person_add_rounded,
                    size: 40,
                    color: Color(0xFF5865F2),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Add New Admin",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 18,
                                color: Color(0xFF1A237E),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "User Type: ADMIN",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                label: "First Name",
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v!.isEmpty ? "Required" : null,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                label: "Last Name",
                                icon: Icons.person_outline,
                                validator: (v) =>
                                    v!.isEmpty ? "Required" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _emailController,
                          label: "Email Address",
                          icon: Icons.email_outlined,
                          validator: (v) {
                            if (v!.isEmpty) return "Email is required";
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v))
                              return "Enter a valid email";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _usernameController,
                          label: "Username",
                          icon: Icons.alternate_email,
                          validator: (v) =>
                              v!.length < 3 ? "Minimum 3 characters" : null,
                        ),
                        const SizedBox(height: 15),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          cursorColor: const Color(0xFF1A237E),
                          cursorWidth: 1.0,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 20,
                              color: Color(0xFF1A237E),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 16,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade500,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF1A237E),
                                width: 1.0,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.red.shade900,
                                width: 1.0,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.red.shade900,
                                width: 1.0,
                              ),
                            ),
                            errorStyle: TextStyle(
                              color: Colors.red.shade900,
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                            ),
                          ),
                          validator: (v) => v!.length < 6
                              ? "Password is too short. It must contain at least 6 characters for security purposes."
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.only(
                bottom: 20,
                left: 20,
                right: 20,
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _isSubmitting = true);

                                  final newUser = {
                                    "firstName": _firstNameController.text,
                                    "lastName": _lastNameController.text,
                                    "email": _emailController.text,
                                    "username": _usernameController.text,
                                    "password": _passwordController.text,
                                    "role": "Admin",
                                    "isActive": true,
                                  };

                                  try {
                                    final provider = Provider.of<AdminProvider>(
                                      context,
                                      listen: false,
                                    );
                                    await provider.insert(newUser);

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Admin user successfully added",
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                      _currentPage = 1;
                                      _fetchUsers();
                                    }
                                  } catch (e) {
                                    setState(() => _isSubmitting = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text("Error: $e"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5865F2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Add Admin",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      cursorColor: const Color(0xFF1A237E),
      cursorWidth: 1.0,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF1A237E)),
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade500, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.0),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade900, width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade900, width: 1.0),
        ),

        errorStyle: TextStyle(
          color: Colors.red.shade900,
          fontWeight: FontWeight.w300,
          fontSize: 12,
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _searchQuery = value;
    if (value.length >= 3 || value.isEmpty) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _currentPage = 1;
        _fetchUsers();
      });
    }
  }

  Widget _buildBackButton() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF1A237E),
        ),
        label: const Text(
          "Back to Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A237E),
            fontSize: 14,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          foregroundColor: const Color(0xFF1A237E),
        ),
      ),
    );
  }

  void _onStatusFilterChanged(String? value) {
    setState(() {
      if (value == "All")
        _statusFilter = null;
      else if (value == "Active")
        _statusFilter = true;
      else if (value == "Inactive")
        _statusFilter = false;
      _currentPage = 1;
    });
    _fetchUsers();
  }

  void _goToNextPage() {
    if (_hasNext) {
      _currentPage++;
      _fetchUsers();
    }
  }

  void _goToPreviousPage() {
    if (_hasPrevious && _currentPage > 1) {
      _currentPage--;
      _fetchUsers();
    }
  }
}
