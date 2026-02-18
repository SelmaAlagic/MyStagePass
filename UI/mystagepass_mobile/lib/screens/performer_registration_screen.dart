import 'package:flutter/material.dart';
import 'package:mystagepass_mobile/models/search_result.dart';
import 'package:provider/provider.dart';
import '../providers/performer_provider.dart';
import '../providers/genre_provider.dart';
import '../models/Genre/genre.dart';
import '../utils/alert_helpers.dart';

class PerformerRegistrationScreen extends StatefulWidget {
  const PerformerRegistrationScreen({super.key});

  @override
  State<PerformerRegistrationScreen> createState() =>
      _PerformerRegistrationScreenState();
}

class _PerformerRegistrationScreenState
    extends State<PerformerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey _genreKey = GlobalKey();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _artistNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  List<Genre> _availableGenres = [];
  List<int> _selectedGenreIds = [];
  bool _isLoading = false;
  bool _isObscured = true;

  final Color _darkBlue = const Color(0xFF1D235D);
  final Color _darkRed = const Color(0xFFB71C1C);
  final Color _darkText = const Color(0xFF1D2939);

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    try {
      var genreProvider = Provider.of<GenreProvider>(context, listen: false);
      SearchResult<Genre> searchResult = await genreProvider.get();
      setState(() {
        _availableGenres = searchResult.result;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showGenresDropdown() async {
    final RenderBox? buttonBox =
        _genreKey.currentContext?.findRenderObject() as RenderBox?;
    if (buttonBox == null) return;

    final offset = buttonBox.localToGlobal(Offset.zero);

    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + buttonBox.size.height,
        offset.dx + buttonBox.size.width,
        0,
      ),
      elevation: 8,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setMenuState) {
              return SizedBox(
                width: buttonBox.size.width,
                height: 220,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _availableGenres.length,
                        itemBuilder: (ctx, index) {
                          final genre = _availableGenres[index];
                          return Theme(
                            data: Theme.of(context).copyWith(
                              visualDensity: const VisualDensity(vertical: -4),
                            ),
                            child: CheckboxListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              value: _selectedGenreIds.contains(genre.genreID),
                              title: Text(
                                genre.name ?? "",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _darkText,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              activeColor: _darkBlue,
                              checkColor: Colors.white,
                              onChanged: (checked) {
                                setMenuState(() {
                                  if (checked!) {
                                    _selectedGenreIds.add(genre.genreID);
                                  } else {
                                    _selectedGenreIds.remove(genre.genreID);
                                  }
                                });
                                setState(() {});
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Done",
                        style: TextStyle(
                          color: _darkBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (_selectedGenreIds.isEmpty) {
      AlertHelpers.showError(context, "Please select at least one genre.");
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        var provider = Provider.of<PerformerProvider>(context, listen: false);

        var request = {
          "firstName": _firstNameController.text,
          "lastName": _lastNameController.text,
          "email": _emailController.text,
          "username": _usernameController.text,
          "artistName": _artistNameController.text,
          "genreIds": _selectedGenreIds,
          "bio": _bioController.text,
          "password": _passwordController.text,
          "passwordConfirm": _confirmPasswordController.text,
          "phoneNumber": _phoneController.text,
          "image": null,
        };

        await provider.register(request);

        if (!mounted) return;

        await AlertHelpers.showAlert(
          context,
          "Registration Successful",
          "Your registration is complete. Please note that your account is currently pending administrator approval. You will be able to log in once your profile has been reviewed and approved.",
        );

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
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
          "Performer Registration",
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
                _buildSectionHeader("Professional Info"),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _artistNameController,
                  label: "Artist Name",
                  icon: Icons.music_note_outlined,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v.length < 5) return "Minimum 5 characters required.";
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                GestureDetector(
                  key: _genreKey,
                  onTap: _showGenresDropdown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: _darkBlue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedGenreIds.isEmpty
                                ? "Select Genres"
                                : "Selected: ${_selectedGenreIds.length} genres",
                            style: TextStyle(
                              color: _selectedGenreIds.isEmpty
                                  ? const Color(0xFF98A2B3)
                                  : _darkText,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: _darkBlue),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildRoundedField(
                  controller: _bioController,
                  label: "Bio",
                  icon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return "This field is required.";
                    if (v.length < 10) return "Minimum 10 characters required.";
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
