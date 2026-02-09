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
import 'package:mystagepass_admin/models/User/user.dart';
import 'package:mystagepass_admin/utils/form_helpers.dart';
import 'package:mystagepass_admin/utils/image_helpers.dart';
import 'package:mystagepass_admin/utils/alert_helpers.dart';
import 'login_screen.dart';
import 'user_management_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;

  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showNotifications = false;

  String _fullName = "";
  String _email = "";
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    String? firstName = await authProvider.getCurrentUserFirstName();
    String? lastName = await authProvider.getCurrentUserLastName();
    String? email = await authProvider.getCurrentUserEmail();

    try {
      var user = await _userProvider.getById(widget.userId);
      setState(() {
        _userData = user;
        _profileImage = user.image;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }

    setState(() {
      if (firstName != null && lastName != null) {
        _fullName = "$firstName $lastName";
      }
      if (email != null) {
        _email = email;
      }
      _isLoadingUserData = false;
    });
  }

  Future<void> _loadNotificationCount() async {
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    await notificationProvider.refreshUnreadCount(widget.userId);
  }

  void _toggleNotifications() {
    setState(() {
      _showNotifications = !_showNotifications;
    });
  }

  void _showEditProfileDialog() {
    if (_userData == null) {
      _showCustomSnackBar('Loading user data...', isSuccess: false);
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Dialog(
              backgroundColor: Colors.transparent,
              child: EditProfileDialog(
                user: _userData!,
                onSaved: () {
                  _loadUserData();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _showEditProfileDialog,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Stack(
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
                                        child: _profileImage != null
                                            ? ImageHelpers.getImage(
                                                _profileImage!,
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
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey[300]!,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 12,
                                          color: Color(0xFF5865F2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            _isLoadingUserData
                                ? const SizedBox(
                                    width: 150,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 16,
                                          width: 100,
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white54,
                                                ),
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        SizedBox(
                                          height: 14,
                                          width: 150,
                                          child: LinearProgressIndicator(
                                            backgroundColor: Colors.white24,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white54,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _email,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        Row(
                          children: [
                            _buildNotificationButton(),
                            const SizedBox(width: 15),
                            _customLogoutButton(
                              onTap: () => _showLogoutDialog(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 1),
                  Text(
                    "Welcome back, ${_fullName.split(' ').first}!",
                    style: const TextStyle(
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
                          _buildIconCard(
                            "Manage users",
                            Icons.manage_accounts_rounded,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const UserManagementScreen(),
                              ),
                            ),
                          ),
                          _buildIconCard(
                            "Manage events",
                            Icons.event_available_rounded,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EventManagementScreen(),
                              ),
                            ),
                          ),
                          _buildIconCard(
                            "Manage performers",
                            Icons.interpreter_mode_rounded,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PerformerManagementScreen(),
                              ),
                            ),
                          ),
                          _buildIconCard(
                            "Reports and stats",
                            Icons.show_chart_rounded,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportsScreen(),
                              ),
                            ),
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
          if (_showNotifications)
            NotificationDropdown(
              userId: widget.userId,
              onViewAll: () {},
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

  Widget _buildNotificationButton() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        return InkWell(
          onTap: _toggleNotifications,
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _showNotifications ? Colors.white : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color.fromARGB(255, 29, 35, 93),
                  size: 22,
                ),
              ),
              if (notificationProvider.unreadCount > 0)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 16),
                    height: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        notificationProvider.unreadCount > 9
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
    );
  }

  Widget _buildIconCard(String title, IconData icon, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color.fromARGB(241, 29, 35, 93),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 35,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3142),
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
            Icon(
              Icons.logout_rounded,
              size: 18,
              color: Color.fromARGB(255, 29, 35, 93),
            ),
            SizedBox(width: 8),
            Text(
              "Logout",
              style: TextStyle(
                color: Color.fromARGB(255, 29, 35, 93),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomSnackBar(String message, {required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: isSuccess
          ? const Color.fromARGB(255, 76, 175, 80)
          : Colors.red,
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showLogoutDialog(BuildContext context) {
    AlertHelpers.showConfirmationAlert(
      context,
      "Logout",
      "Are you sure you want to logout? You will need to login again to access the admin panel.",
      confirmButtonText: "Logout",
      cancelButtonText: "Cancel",
      isDelete: true,
      onConfirm: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();

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

class EditProfileDialog extends StatefulWidget {
  final User user;
  final VoidCallback onSaved;

  const EditProfileDialog({Key? key, required this.user, required this.onSaved})
    : super(key: key);

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final UserProvider _userProvider = UserProvider();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  File? _selectedImage;
  String? _base64Image;
  bool _isLoading = false;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String? _currentPasswordError;
  bool _isHoveringRemoveButton = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.user.firstName ?? '',
    );
    _lastNameController = TextEditingController(
      text: widget.user.lastName ?? '',
    );
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _usernameController = TextEditingController(
      text: widget.user.username ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.user.phoneNumber ?? '',
    );
    _base64Image = widget.user.image;

    _currentPasswordController.addListener(() {
      if (_currentPasswordError != null) {
        setState(() {
          _currentPasswordError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _selectedImage = file;
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _base64Image = null;
    });
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _currentPasswordError = null;
    });

    final hasNewPassword = _newPasswordController.text.isNotEmpty;
    final hasCurrentPassword = _currentPasswordController.text.isNotEmpty;
    final hasConfirmPassword = _confirmPasswordController.text.isNotEmpty;

    if (hasNewPassword) {
      if (!hasCurrentPassword) {
        setState(() {
          _currentPasswordError = "Please enter your current password";
        });
        return;
      }
      if (!hasConfirmPassword) {
        _showCustomSnackBar(
          'Please confirm your new password',
          isSuccess: false,
        );
        return;
      }
      if (_newPasswordController.text.length < 6) {
        _showCustomSnackBar(
          'New password must be at least 6 characters',
          isSuccess: false,
        );
        return;
      }
      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showCustomSnackBar('New passwords do not match', isSuccess: false);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final updateRequest = <String, dynamic>{
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'phoneNumber': _phoneController.text.isEmpty
            ? null
            : _phoneController.text,
      };

      updateRequest['image'] = _base64Image;

      if (_newPasswordController.text.isNotEmpty) {
        updateRequest['currentPassword'] = _currentPasswordController.text;
        updateRequest['password'] = _newPasswordController.text;
        updateRequest['passwordConfirm'] = _confirmPasswordController.text;
      }

      await _userProvider.update(widget.user.userId!, updateRequest);

      if (!mounted) return;

      widget.onSaved();
      Navigator.pop(context);
      _showCustomSnackBar('Profile updated successfully!', isSuccess: true);

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      String errorMessage = e.toString();

      if (errorMessage.contains('Exception: ')) {
        errorMessage = errorMessage.split('Exception: ').last.trim();
      }

      if (errorMessage.toLowerCase().contains('password') ||
          errorMessage.toLowerCase().contains('current') ||
          errorMessage.toLowerCase().contains('confirmation')) {
        setState(() {
          _currentPasswordError = errorMessage;
        });
      } else {
        _showCustomSnackBar(errorMessage, isSuccess: false);
      }
    }
  }

  void _showCustomSnackBar(String message, {required bool isSuccess}) {
    final snackBar = SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: isSuccess
          ? const Color.fromARGB(255, 76, 175, 80)
          : Colors.red,
      elevation: 6,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _buildUserTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAF6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.admin_panel_settings,
            size: 16,
            color: Color(0xFF1A237E),
          ),
          const SizedBox(width: 6),
          Text(
            "User Type: ADMIN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A237E),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 700,
        height: 700,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF5865F2),
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          )
                                        : ImageHelpers.getImage(
                                            _base64Image,
                                            height: 90,
                                            width: 90,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF5865F2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (_selectedImage != null ||
                            (_base64Image != null && _base64Image!.isNotEmpty))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              onEnter: (_) => setState(
                                () => _isHoveringRemoveButton = true,
                              ),
                              onExit: (_) => setState(
                                () => _isHoveringRemoveButton = false,
                              ),
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isHoveringRemoveButton
                                        ? Colors.red.shade50
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        size: 16,
                                        color: _isHoveringRemoveButton
                                            ? Colors.red.shade900
                                            : Colors.red.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Remove Picture',
                                        style: TextStyle(
                                          color: _isHoveringRemoveButton
                                              ? Colors.red.shade900
                                              : Colors.red.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),
                        _buildUserTypeBadge(),
                        const SizedBox(height: 20),

                        FormHelpers.drawFormRow(
                          children: [
                            FormHelpers.drawModernTextField(
                              controller: _firstNameController,
                              label: "First Name",
                              icon: Icons.person_outline,
                              required: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "First name is required";
                                if (value.length < 3)
                                  return "Minimum 3 characters";
                                return null;
                              },
                            ),
                            FormHelpers.drawModernTextField(
                              controller: _lastNameController,
                              label: "Last Name",
                              icon: Icons.person_outline,
                              required: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Last name is required";
                                if (value.length < 3)
                                  return "Minimum 3 characters";
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        FormHelpers.drawFormRow(
                          children: [
                            FormHelpers.drawModernTextField(
                              controller: _emailController,
                              label: "Email",
                              icon: Icons.email_outlined,
                              required: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Email is required";
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return "Enter a valid email address";
                                }
                                return null;
                              },
                            ),
                            FormHelpers.drawModernTextField(
                              controller: _usernameController,
                              label: "Username",
                              icon: Icons.alternate_email,
                              required: true,
                              validator: (value) {
                                if (value == null || value.isEmpty)
                                  return "Username is required";
                                if (value.length < 5)
                                  return "Minimum 5 characters";
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: FormHelpers.drawFormRow(
                            children: [
                              FormHelpers.drawModernTextField(
                                controller: _phoneController,
                                label: "Phone Number",
                                icon: Icons.phone_outlined,
                                required: false,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return null;
                                  if (!RegExp(
                                    r'^\+?0?\d{8,14}$',
                                  ).hasMatch(value)) {
                                    return "Invalid phone number (8-14 digits)";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox.shrink(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.grey[300]!,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Leave empty if you don\'t want to change password',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: FormHelpers.drawFormRow(
                            children: [
                              FormHelpers.drawModernTextField(
                                controller: _currentPasswordController,
                                label: "Current Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _obscureCurrentPassword,
                                onTogglePassword: () {
                                  setState(
                                    () => _obscureCurrentPassword =
                                        !_obscureCurrentPassword,
                                  );
                                },
                                required: false,
                                validator: (value) {
                                  if (_newPasswordController.text.isNotEmpty) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your current password";
                                    }
                                  }
                                  return null;
                                },
                                serverError: _currentPasswordError,
                                onChanged: () {
                                  if (_currentPasswordError != null) {
                                    setState(() {
                                      _currentPasswordError = null;
                                    });
                                  }
                                },
                              ),
                              SizedBox.shrink(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        FormHelpers.drawFormRow(
                          children: [
                            FormHelpers.drawModernTextField(
                              controller: _newPasswordController,
                              label: "New Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: _obscureNewPassword,
                              onTogglePassword: () {
                                setState(
                                  () => _obscureNewPassword =
                                      !_obscureNewPassword,
                                );
                              },
                              required: false,
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    value.length < 6) {
                                  return "Minimum 6 characters";
                                }
                                return null;
                              },
                            ),
                            FormHelpers.drawModernTextField(
                              controller: _confirmPasswordController,
                              label: "Confirm New Password",
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: _obscureConfirmPassword,
                              onTogglePassword: () {
                                setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                );
                              },
                              required: false,
                              validator: (value) {
                                if (_newPasswordController.text.isNotEmpty) {
                                  if (value == null || value.isEmpty) {
                                    return "Please confirm your new password";
                                  }
                                  if (value != _newPasswordController.text) {
                                    return "Passwords do not match";
                                  }
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                FormHelpers.drawFormRow(
                  children: [
                    FormHelpers.drawModernOutlinedButton(
                      label: "Cancel",
                      onPressed: () => Navigator.pop(context),
                    ),
                    FormHelpers.drawModernElevatedButton(
                      label: "Save Changes",
                      onPressed: _saveChanges,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
