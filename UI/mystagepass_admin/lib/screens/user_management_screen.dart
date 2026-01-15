import 'package:flutter/material.dart';
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
                      await provider.delete(user.userId!);

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _actionIcon(
          Icons.edit,
          const Color(0xFFFBC02D),
          const Color(0xFFFFF9C4),
          onTap: () {},
        ),
        const SizedBox(width: 8),
        _actionIcon(
          Icons.delete,
          const Color(0xFFE53935),
          const Color(0xFFFFEBEE),
          onTap: () {
            _showDeleteConfirmation(user);
          },
        ),
      ],
    );
  }

  Widget _actionIcon(
    IconData icon,
    Color color,
    Color bg, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 14),
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
        onPressed: () {},
        icon: const Icon(Icons.person_add_alt_1, size: 18),
        label: const Text("Add new user"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
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
