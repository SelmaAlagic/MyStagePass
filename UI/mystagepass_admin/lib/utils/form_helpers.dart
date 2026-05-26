import 'package:flutter/material.dart';

const _navy = Color(0xFF1D2359);
const _navyMid = Color(0xFF2D3A8C);
const _blue = Color(0xFF2D3A8C);
const _blue50 = Color(0xFFF0F3FF);
const _blue100 = Color(0xFFE8EDFF);
const _white = Color(0xFFFFFFFF);
const _bg = Color(0xFFF4F6FB);
const _card = Color(0xFFFFFFFF);
const _border = Color(0xFFECEFF8);
const _t1 = Color(0xFF1E2642);
const _t2 = Color(0xFF8A93B2);
const _green = Color(0xFF22C55E);

class FormHelpers {
  static Widget drawProgressIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(color: _blue),
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
    String? serverError,
    VoidCallback? onChanged,
  }) {
    final borderRadius = BorderRadius.circular(12);
    final enabledColor = serverError != null
        ? const Color(0xFFD32F2F)
        : _border;
    final focusedColor = serverError != null ? const Color(0xFFD32F2F) : _blue;

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: (_) => onChanged?.call(),
      cursorColor: _blue,
      cursorWidth: 1.5,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w500,
        color: enabled ? _t1 : _t2,
      ),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: enabled ? _t2 : _t2.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 12,
          color: _blue,
          fontWeight: FontWeight.w600,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: _t2.withOpacity(0.6), fontSize: 13),

        prefixIcon: Icon(icon, size: 17, color: enabled ? _blue : _t2),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 42,
          minHeight: 42,
        ),

        suffixIcon: isPassword && onTogglePassword != null
            ? IconButton(
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                  color: _t2,
                ),
                splashRadius: 18,
                onPressed: enabled ? onTogglePassword : null,
              )
            : null,

        isDense: true,
        filled: true,
        fillColor: enabled ? _white : _bg,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 13,
          horizontal: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: enabledColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: focusedColor, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: _border.withOpacity(0.6), width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
        ),

        errorText: serverError,
        errorStyle: const TextStyle(
          color: Color(0xFFD32F2F),
          fontWeight: FontWeight.w400,
          fontSize: 11.5,
        ),
      ),
    );
  }

  static Widget drawModernOutlinedButton({
    required String label,
    required VoidCallback onPressed,
    Color color = _t2,
    bool isLoading = false,
    bool enabled = true,
    IconData? icon,
  }) {
    final active = enabled && !isLoading;
    return OutlinedButton(
      onPressed: active ? onPressed : null,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        side: BorderSide(color: active ? color : _border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: active ? color : _t2,
      ),
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: _t2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: active ? color : _t2,
                  ),
                ),
              ],
            ),
    );
  }

  static Widget drawModernElevatedButton({
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = _blue,
    bool isLoading = false,
    bool enabled = true,
    IconData? icon,
  }) {
    final active = enabled && !isLoading;
    return ElevatedButton(
      onPressed: active ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: _white,
        disabledBackgroundColor: backgroundColor.withOpacity(0.55),
        disabledForegroundColor: _white.withOpacity(0.7),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        elevation: active ? 2 : 0,
        shadowColor: backgroundColor.withOpacity(0.35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(color: _white, strokeWidth: 2),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
    );
  }

  static Widget drawUserTypeBadge(String userType) {
    Color bg;
    Color fg;
    IconData icon;

    switch (userType.toUpperCase()) {
      case 'ADMIN':
        bg = _blue100;
        fg = _navyMid;
        icon = Icons.admin_panel_settings_rounded;
        break;
      case 'PERFORMER':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF6D28D9);
        icon = Icons.mic_external_on_rounded;
        break;
      case 'CUSTOMER':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.person_rounded;
        break;
      default:
        bg = _bg;
        fg = _t2;
        icon = Icons.person_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            'User Type: $userType',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: fg,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  static Widget drawFormRow({
    required List<Widget> children,
    double spacing = 14,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: children[i]),
        ],
      ],
    );
  }

  static Widget drawSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _t1,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
