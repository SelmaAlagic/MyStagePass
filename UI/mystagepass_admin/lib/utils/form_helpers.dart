import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class FormHelpers {
  static Widget drawStringContainer(
    String hint,
    String propertyName, {
    bool obscureText = false,
    int minLength = 5,
    int maxLength = 40,
    List<String? Function(String?)> customValidators = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(maxHeight: 81, maxWidth: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            FormBuilderTextField(
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Field is required"),
                FormBuilderValidators.minLength(minLength),
                FormBuilderValidators.maxLength(maxLength),
                ...customValidators,
              ]),
              name: propertyName,
              obscureText: obscureText,
              decoration: InputDecoration(
                label: Text(hint),
                labelStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
                hintText: "$hint*",
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget drawNumericContainer(
    String hint,
    String propertyName, {
    bool allowNegative = false,
    bool integer = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: Alignment.centerLeft,
      constraints: const BoxConstraints(maxHeight: 81, maxWidth: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8),
        child: Column(
          children: [
            FormBuilderTextField(
              keyboardType: TextInputType.number,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: "Field is required"),
                FormBuilderValidators.numeric(),
                integer
                    ? FormBuilderValidators.integer()
                    : FormBuilderValidators.numeric(),
                !allowNegative
                    ? FormBuilderValidators.positiveNumber()
                    : FormBuilderValidators.numeric(),
                FormBuilderValidators.min(0),
              ]),
              name: propertyName,
              decoration: InputDecoration(
                label: Text(hint),
                labelStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
                hintText: "$hint*",
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget drawProgressIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }

  static Widget drawModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    int? maxLines = 1,
    bool enabled = true,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      cursorColor: const Color(0xFF1A237E),
      cursorWidth: 1.0,
      style: TextStyle(
        fontSize: 14,
        color: enabled ? Colors.black87 : Colors.grey.shade600,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        labelText: required ? "$label*" : label,
        labelStyle: TextStyle(
          color: enabled ? Colors.grey.shade700 : Colors.grey.shade500,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        prefixIcon: Icon(
          icon,
          size: 20,
          color: enabled ? const Color(0xFF1A237E) : Colors.grey.shade500,
        ),
        suffixIcon: isPassword && onTogglePassword != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                  color: enabled ? Colors.grey.shade700 : Colors.grey.shade500,
                ),
                onPressed: enabled ? onTogglePassword : null,
              )
            : null,
        isDense: true,
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0),
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

  static Widget drawModernOutlinedButton({
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.grey,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return OutlinedButton(
      onPressed: enabled && !isLoading ? onPressed : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        side: BorderSide(
          color: enabled && !isLoading ? color : Colors.grey.shade400,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(
              label,
              style: TextStyle(
                color: enabled && !isLoading ? color : Colors.grey.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }

  static Widget drawModernElevatedButton({
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF5865F2),
    bool isLoading = false,
    bool enabled = true,
  }) {
    return ElevatedButton(
      onPressed: enabled && !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled && !isLoading
            ? backgroundColor
            : backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  static Widget drawUserTypeBadge(String userType) {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (userType.toUpperCase()) {
      case 'ADMIN':
        bgColor = const Color(0xFFE8EAF6);
        iconColor = const Color(0xFF1A237E);
        icon = Icons.admin_panel_settings;
        break;
      case 'PERFORMER':
        bgColor = const Color(0xFFF3E5F5);
        iconColor = const Color(0xFF4A148C);
        icon = Icons.music_note;
        break;
      case 'CUSTOMER':
        bgColor = const Color(0xFFE8F5E9);
        iconColor = const Color(0xFF1B5E20);
        icon = Icons.person;
        break;
      default:
        bgColor = const Color(0xFFF5F5F5);
        iconColor = Colors.grey;
        icon = Icons.person_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            "User Type: $userType",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  static Widget drawSimpleDialogHeader({
    required String title,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 42, color: const Color(0xFF5865F2)),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  static Widget drawFormRow({
    required List<Widget> children,
    double spacing = 15,
  }) {
    return Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }

  static Widget drawFormSection({
    required String title,
    required Widget child,
    double topPadding = 20,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A237E),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        child,
        SizedBox(height: topPadding),
      ],
    );
  }
}
