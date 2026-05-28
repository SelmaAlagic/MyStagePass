import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/authorization.dart';
import 'admin_home_screen.dart';

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
          int? userId = await authProvider.getCurrentUserId();

          if (!mounted) return;

          if (userId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(userId: userId),
              ),
            );
          } else {
            setState(() => _errorMessage = "Error loading user data.");
          }
        } else {
          setState(
            () => _errorMessage = "Your username or password is incorrect.",
          );
        }
      } catch (e) {
        setState(
          () => _errorMessage = "Your username or password is incorrect.",
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          selectionColor: Color(0xFFD7E3FF),
          cursorColor: Color(0xFF1D235D),
        ),
      ),
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerLeft,
              ),
            ),

            Row(
              children: [
                Expanded(
                  flex: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 150,
                      top: 240,
                      bottom: 44,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          "Access your events.\nManage with ease.",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Sign in to your admin account\nand take control of your events.",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.65,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 60,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Center(
                      child: SizedBox(
                        width: 380,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/MyStagePassLogo.png',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 60),

                              const Text(
                                "Welcome back, Admin!",
                                style: TextStyle(
                                  color: Color(0xFF1D2939),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                "Please enter your credentials to continue",
                                style: TextStyle(
                                  color: Color(0xFF667085),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 36),

                              TextFormField(
                                controller: _usernameController,
                                cursorWidth: 0.5,
                                style: const TextStyle(
                                  color: Color(0xFF1D2939),
                                  fontSize: 13,
                                ),
                                decoration: _inputDecoration(
                                  "Username",
                                  Icons.person_outline,
                                ),
                                validator: (value) =>
                                    value!.isEmpty ? "Enter username" : null,
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: _passwordController,
                                cursorWidth: 0.5,
                                obscureText: _isObscured,
                                style: const TextStyle(
                                  color: Color(0xFF1D2939),
                                  fontSize: 13,
                                ),
                                decoration: _inputDecoration(
                                  "Password",
                                  Icons.lock_outline,
                                  isPassword: true,
                                ),
                                onFieldSubmitted: (_) => _handleLogin(),
                                validator: (value) =>
                                    value!.isEmpty ? "Enter password" : null,
                              ),

                              if (_errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 36),

                              SizedBox(
                                width: double.infinity,
                                height: 42,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1D235D),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Log in",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF667085), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF1D235D), size: 20),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontWeight: FontWeight.w300,
        fontSize: 11,
      ),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFF1D235D),
                size: 18,
              ),
              onPressed: () => setState(() => _isObscured = !_isObscured),
            )
          : null,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFB0B7C3), width: 1.0),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Color(0xFF1D235D), width: 1.5),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red.shade200, width: 1.0),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 1.2),
      ),
    );
  }
}
