import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/customer_provider.dart';
import '../utils/alert_helpers.dart';

class CustomerRegistrationScreen extends StatefulWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  State<CustomerRegistrationScreen> createState() =>
      _CustomerRegistrationScreenState();
}

class _CustomerRegistrationScreenState
    extends State<CustomerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isObscured = true;

  final Color _darkBlue = const Color(0xFF1D235D);
  final Color _darkRed = const Color(0xFFB71C1C);
  final Color _darkText = const Color(0xFF1D2939);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        var provider = Provider.of<CustomerProvider>(context, listen: false);

        var request = {
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "email": _emailController.text,
          "username": _usernameController.text,
          "password": _passwordController.text,
          "passwordConfirm": _confirmPasswordController.text,
          "phoneNumber": _phoneController.text,
          "image": null,
        };

        var response = await provider.register(request);

        if (response != null) {
          if (!mounted) return;
          await AlertHelpers.showAlert(
            context,
            "Registration Successful",
            "Your account has been created successfully. Please login to access all the platform features!",
            isSuccess: true,
          );
          if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } catch (e) {
        if (!mounted) return;
        AlertHelpers.showError(
          context,
          e.toString().replaceAll("Exception: ", ""),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _darkBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Customer Registration",
          style: TextStyle(color: _darkBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Personal Details"),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _firstNameController,
                  label: "First Name",
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v.length < 3) return "Minimum 3 characters required.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _lastNameController,
                  label: "Last Name",
                  icon: Icons.person_outline,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v.length < 3) return "Minimum 3 characters required.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (!RegExp(r"^\+?0?\d{8,14}$").hasMatch(v))
                      return "Invalid phone number.";
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _buildSectionHeader("Account Credentials"),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _emailController,
                  label: "Email",
                  icon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(v))
                      return "Invalid e-mail format.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _usernameController,
                  label: "Username",
                  icon: Icons.alternate_email,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v.length < 5) return "Minimum 5 characters required.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _passwordController,
                  label: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v.length < 6) return "Minimum 6 characters required.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_reset,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v != _passwordController.text)
                      return "Passwords do not match.";
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
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

  Widget _buildRoundedField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool isPassword = false,
    int maxLines = 1,
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
        obscureText: isPassword ? _isObscured : false,
        maxLines: maxLines,
        validator: validator,
        cursorColor: _darkBlue,
        style: TextStyle(fontSize: 14, color: _darkText),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF98A2B3)),
          floatingLabelStyle: TextStyle(color: _darkBlue),
          prefixIcon: Icon(icon, color: _darkBlue, size: 20),
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
}
