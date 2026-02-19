import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/alert_helpers.dart';
import '../utils/image_helpers.dart';
import '../widgets/bottom_nav_bar.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _personalFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoadingPersonal = false;
  bool _isLoadingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _newImageBase64;
  bool _removeImage = false;
  bool _hasPersonalChanges = false;
  bool _hasPasswordInput = false;

  String? _currentPasswordError;
  String? _newPasswordError;

  String? _originalFirstName;
  String? _originalLastName;
  String? _originalEmail;
  String? _originalUsername;
  String? _originalPhone;

  final Color _darkBlue = const Color(0xFF1D235D);
  final Color _darkRed = const Color(0xFFB71C1C);
  final Color _darkText = const Color(0xFF1D2939);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser == null) {
        auth.fetchMyProfile().then((_) => _prefillFields());
      } else {
        _prefillFields();
      }
    });

    _currentPasswordController.addListener(() {
      if (_currentPasswordError != null)
        setState(() => _currentPasswordError = null);
      _checkPasswordInput();
    });
    _newPasswordController.addListener(() {
      if (_newPasswordError != null) setState(() => _newPasswordError = null);
      _checkPasswordInput();
    });
    _confirmPasswordController.addListener(_checkPasswordInput);
  }

  void _prefillFields() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) return;

    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _emailController.text = user.email ?? '';
    _usernameController.text = user.username ?? '';
    _phoneController.text = user.phoneNumber ?? '';

    _originalFirstName = user.firstName ?? '';
    _originalLastName = user.lastName ?? '';
    _originalEmail = user.email ?? '';
    _originalUsername = user.username ?? '';
    _originalPhone = user.phoneNumber ?? '';

    _firstNameController.addListener(_checkChanges);
    _lastNameController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _usernameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed =
        _firstNameController.text != _originalFirstName ||
        _lastNameController.text != _originalLastName ||
        _emailController.text != _originalEmail ||
        _usernameController.text != _originalUsername ||
        _phoneController.text != _originalPhone ||
        _newImageBase64 != null ||
        _removeImage;
    if (changed != _hasPersonalChanges) {
      setState(() => _hasPersonalChanges = changed);
    }
  }

  void _checkPasswordInput() {
    final hasInput =
        _currentPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty;
    if (hasInput != _hasPasswordInput) {
      setState(() => _hasPasswordInput = hasInput);
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF2E7D32),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE8F5E9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF2E7D32), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_rounded, color: Color(0xFFB71C1C), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF7F0000),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFEBEE),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFB71C1C), width: 1),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (picked != null) {
      final bytes = await File(picked.path).readAsBytes();
      setState(() {
        _newImageBase64 = base64Encode(bytes);
        _removeImage = false;
        _hasPersonalChanges = true;
      });
    }
  }

  void _removeImageAction() {
    setState(() {
      _newImageBase64 = null;
      _removeImage = true;
      _hasPersonalChanges = true;
    });
  }

  Future<void> _handlePersonalUpdate() async {
    if (!_personalFormKey.currentState!.validate()) return;
    setState(() => _isLoadingPersonal = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);

      String? imageToSend;
      if (_removeImage) {
        imageToSend = null;
      } else if (_newImageBase64 != null) {
        imageToSend = _newImageBase64;
      } else {
        imageToSend = auth.currentUser?.image;
      }

      await auth.updateProfile(widget.userId, {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'phoneNumber': _phoneController.text.isEmpty
            ? null
            : _phoneController.text,
        'image': imageToSend,
      });

      auth.currentUser = null;
      auth.profileImageBytes = null;
      await auth.fetchMyProfile();

      if (!mounted) return;
      setState(() {
        _removeImage = false;
        _newImageBase64 = null;
        _hasPersonalChanges = false;
        _originalFirstName = _firstNameController.text;
        _originalLastName = _lastNameController.text;
        _originalEmail = _emailController.text;
        _originalUsername = _usernameController.text;
        _originalPhone = _phoneController.text;
      });
      _showSuccessSnackbar("Profile updated successfully.");
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackbar(e.toString().replaceAll("Exception: ", ""));
    } finally {
      if (mounted) setState(() => _isLoadingPersonal = false);
    }
  }

  void _showPasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Leave empty if you don't want to change password",
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      controller: _currentPasswordController,
                      label: "Current Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscure: _obscureCurrent,
                      serverError: _currentPasswordError,
                      onToggleObscure: () => setSheetState(
                        () => _obscureCurrent = !_obscureCurrent,
                      ),
                      onChanged: () {
                        if (_currentPasswordError != null)
                          setSheetState(() => _currentPasswordError = null);
                        setSheetState(() => _checkPasswordInput());
                      },
                      validator: (v) {
                        if (_newPasswordController.text.isNotEmpty &&
                            (v == null || v.isEmpty))
                          return "Please enter your current password";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _newPasswordController,
                      label: "New Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscure: _obscureNew,
                      serverError: _newPasswordError,
                      onToggleObscure: () =>
                          setSheetState(() => _obscureNew = !_obscureNew),
                      onChanged: () {
                        if (_newPasswordError != null)
                          setSheetState(() => _newPasswordError = null);
                        setSheetState(() => _checkPasswordInput());
                      },
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6)
                          return "Minimum 6 characters";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: "Confirm New Password",
                      icon: Icons.lock_reset,
                      isPassword: true,
                      obscure: _obscureConfirm,
                      onToggleObscure: () => setSheetState(
                        () => _obscureConfirm = !_obscureConfirm,
                      ),
                      onChanged: () =>
                          setSheetState(() => _checkPasswordInput()),
                      validator: (v) {
                        if (_newPasswordController.text.isNotEmpty) {
                          if (v == null || v.isEmpty)
                            return "Please confirm your new password";
                          if (v != _newPasswordController.text)
                            return "Passwords do not match";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: (!_hasPasswordInput || _isLoadingPassword)
                            ? null
                            : () async {
                                if (!_passwordFormKey.currentState!.validate())
                                  return;
                                setSheetState(() => _isLoadingPassword = true);
                                try {
                                  final auth = Provider.of<AuthProvider>(
                                    context,
                                    listen: false,
                                  );
                                  await auth.updateProfile(widget.userId, {
                                    'currentPassword':
                                        _currentPasswordController.text,
                                    'password': _newPasswordController.text,
                                    'passwordConfirm':
                                        _confirmPasswordController.text,
                                  });
                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                  if (!mounted) return;
                                  Navigator.pop(ctx);
                                  _showSuccessSnackbar(
                                    "Password changed successfully.",
                                  );
                                } catch (e) {
                                  String error = e.toString().replaceAll(
                                    "Exception: ",
                                    "",
                                  );
                                  if (error.toLowerCase().contains('current') ||
                                      error.toLowerCase().contains(
                                        'incorrect',
                                      )) {
                                    setSheetState(
                                      () => _currentPasswordError = error,
                                    );
                                  } else if (error.toLowerCase().contains(
                                    'password',
                                  )) {
                                    setSheetState(
                                      () => _newPasswordError = error,
                                    );
                                  } else {
                                    if (!mounted) return;
                                    Navigator.pop(ctx);
                                    _showErrorSnackbar(error);
                                  }
                                } finally {
                                  if (mounted)
                                    setSheetState(
                                      () => _isLoadingPassword = false,
                                    );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _hasPasswordInput
                              ? _darkBlue
                              : const Color(0xFFE8EAF2),
                          foregroundColor: _hasPasswordInput
                              ? Colors.white
                              : const Color(0xFF9FA8C4),
                          disabledBackgroundColor: const Color(0xFFE8EAF2),
                          disabledForegroundColor: const Color(0xFF9FA8C4),
                          elevation: _hasPasswordInput ? 2 : 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoadingPassword
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Change Password",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selected: NavItem.profile,
        userId: widget.userId,
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final hasImage =
              (auth.profileImageBytes != null &&
                  !_removeImage &&
                  _newImageBase64 == null) ||
              _newImageBase64 != null;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: ClipOval(
                                child: _newImageBase64 != null
                                    ? Image.memory(
                                        base64Decode(_newImageBase64!),
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                      )
                                    : _removeImage ||
                                          auth.profileImageBytes == null
                                    ? Image.asset(
                                        'assets/images/NoProfileImage.png',
                                        height: 90,
                                        width: 90,
                                        fit: BoxFit.cover,
                                      )
                                    : ImageHelpers.getImageFromBytes(
                                        auth.profileImageBytes,
                                        height: 90,
                                        width: 90,
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _pickImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _darkBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (hasImage)
                          GestureDetector(
                            onTap: _removeImageAction,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  size: 14,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Remove Picture",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.red[400],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: _pickImage,
                            child: Text(
                              "Tap to upload photo",
                              style: TextStyle(
                                fontSize: 13,
                                color: _darkBlue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _personalFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Personal Info"),
                        const SizedBox(height: 15),
                        _buildField(
                          controller: _firstNameController,
                          label: "First Name",
                          icon: Icons.person_outline,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "First name is required";
                            if (v.length < 3) return "Minimum 3 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _lastNameController,
                          label: "Last Name",
                          icon: Icons.person_outline,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Last name is required";
                            if (v.length < 3) return "Minimum 3 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _emailController,
                          label: "Email",
                          icon: Icons.email_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Email is required";
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(v))
                              return "Enter a valid email address";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _usernameController,
                          label: "Username",
                          icon: Icons.alternate_email,
                          validator: (v) {
                            if (v == null || v.isEmpty)
                              return "Username is required";
                            if (v.length < 5) return "Minimum 5 characters";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _phoneController,
                          label: "Phone Number",
                          icon: Icons.phone_outlined,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null;
                            if (!RegExp(r'^\+?0?\d{8,14}$').hasMatch(v))
                              return "Invalid phone number (8-14 digits)";
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (!_hasPersonalChanges)
                          Padding(padding: const EdgeInsets.only(bottom: 8)),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            onPressed:
                                (_hasPersonalChanges && !_isLoadingPersonal)
                                ? _handlePersonalUpdate
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasPersonalChanges
                                  ? _darkBlue
                                  : const Color(0xFFE8EAF2),
                              foregroundColor: _hasPersonalChanges
                                  ? Colors.white
                                  : const Color(0xFF9FA8C4),
                              disabledBackgroundColor: const Color(0xFFE8EAF2),
                              disabledForegroundColor: const Color(0xFF9FA8C4),
                              elevation: _hasPersonalChanges ? 2 : 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoadingPersonal
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Save Changes",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionHeader("Security"),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _showPasswordSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEAECF0)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, color: _darkBlue, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Change Password",
                              style: TextStyle(
                                fontSize: 14,
                                color: _darkText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () => _showLogoutDialog(
                      Provider.of<AuthProvider>(context, listen: false),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.red[400],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _darkBlue,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: Color(0xFFEAECF0), thickness: 1)),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    VoidCallback? onChanged,
    String? serverError,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _darkBlue,
          primary: _darkBlue,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        validator: validator,
        cursorColor: _darkBlue,
        style: TextStyle(fontSize: 14, color: _darkText),
        onChanged: onChanged != null ? (_) => onChanged() : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF98A2B3)),
          floatingLabelStyle: TextStyle(color: _darkBlue),
          prefixIcon: Icon(icon, color: _darkBlue, size: 20),
          errorText: serverError,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF98A2B3),
                    size: 20,
                  ),
                  onPressed: onToggleObscure,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEAECF0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _darkBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _darkRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: _darkRed, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(AuthProvider auth) {
    AlertHelpers.showConfirmationAlert(
      context,
      "Logout",
      "Are you sure you want to logout?",
      confirmButtonText: "Logout",
      cancelButtonText: "Cancel",
      isDelete: true,
      onConfirm: () async {
        await auth.logout();
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
