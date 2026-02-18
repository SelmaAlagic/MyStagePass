import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/screens/performer_registration_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/authorization.dart';
import '../utils/alert_helpers.dart';
import 'customer_home_screen.dart';
import 'performer_home_screen.dart';
import 'customer_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isObscured = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showStatusDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF1D2939),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            color: Color(0xFF667085),
            height: 1.5,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Understood",
                  style: TextStyle(
                    color: Color(0xFF1D235D),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Authorization.username = _usernameController.text;
        Authorization.password = _passwordController.text;

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final response = await authProvider.login();

        if (response.result == 0) {
          await authProvider.fetchCurrentUserInfo();
          if (!mounted) return;

          final role = authProvider.currentUserInfo?['role'] as String?;
          final userId = authProvider.currentUserInfo?['userId'] as int?;

          if (userId != null && role != null) {
            Widget homeScreen = role == 'Performer'
                ? PerformerHomeScreen(userId: userId)
                : CustomerHomeScreen(userId: userId);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => homeScreen),
            );
          }
        } else {
          setState(
            () => _errorMessage = "Your username or password is incorrect.",
          );
        }
      } catch (e) {
        String errorMsg = e.toString().replaceAll("Exception: ", "");

        if (errorMsg.startsWith("PENDING:")) {
          String cleanMessage = errorMsg.replaceFirst("PENDING:", "");
          AlertHelpers.showAlert(context, "Pending Approval", cleanMessage);
        } else if (errorMsg.startsWith("REJECTED:")) {
          String cleanMessage = errorMsg.replaceFirst("REJECTED:", "");
          AlertHelpers.showAlert(
            context,
            "Account Rejected",
            cleanMessage,
            isError: true,
          );
        } else {
          setState(() => _errorMessage = errorMsg);
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showRegisterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 35,
              height: 3,
              margin: const EdgeInsets.only(bottom: 25),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Select Account Type",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1D2939),
              ),
            ),
            const SizedBox(height: 25),
            _buildRoleOption(
              "I am a Customer",
              "Discover and book amazing events!",
              Icons.person_search_outlined,
            ),
            const SizedBox(height: 12),
            _buildRoleOption(
              "I am a Performer",
              "Showcase your talent and grow your career!",
              Icons.mic_external_on_outlined,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(String title, String subtitle, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        if (title.contains("Customer")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerRegistrationScreen(),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PerformerRegistrationScreen(),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEAECF0)),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1D235D), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF1D2939),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFF98A2B3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFFB3E5FC),
          selectionHandleColor: Color(0xFF1D235D),
          cursorColor: Color(0xFF1D235D),
        ),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/images/MyStagePassLogo.png',
                  height: 110,
                  fit: BoxFit.contain,
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Welcome back!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF1D2939),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Please enter your credentials",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 45),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildLineField(
                                controller: _usernameController,
                                label: "Username",
                                icon: Icons.person_outline,
                                validator: (value) =>
                                    value!.isEmpty ? "Enter username" : null,
                              ),
                              const SizedBox(height: 25),
                              _buildLineField(
                                controller: _passwordController,
                                label: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validator: (value) =>
                                    value!.isEmpty ? "Enter password" : null,
                              ),
                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 50),
                              SizedBox(
                                width: 180,
                                height: 44,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D235D),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF667085),
                                fontSize: 15,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showRegisterOptions,
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Color(0xFF1D235D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? _isObscured : false,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1D2939)),
      cursorColor: const Color(0xFF1D235D),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF1D235D),
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF1D235D), size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 40),
        errorStyle: const TextStyle(
          color: Color(0xFFD32F2F),
          fontWeight: FontWeight.w400,
          fontSize: 12,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF98A2B3),
                  size: 20,
                ),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              )
            : null,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFEAECF0), width: 1.0),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1D235D), width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.0),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }
}
