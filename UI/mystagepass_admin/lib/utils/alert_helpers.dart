import 'package:flutter/material.dart';

class AlertHelpers {
  static void showAlert(
    BuildContext context,
    String title,
    String text, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    bool autoSuccess = title.toLowerCase() == "success";
    bool autoError = title.toLowerCase() == "error";

    final bool shouldShowSuccess = isSuccess || autoSuccess;
    final bool shouldShowError = isError || autoError;

    Color backgroundColor;
    Color iconColor;
    Color titleColor;
    IconData icon;

    if (shouldShowSuccess) {
      backgroundColor = const Color(0xFFE8F5E9);
      iconColor = Colors.green;
      titleColor = Colors.green.shade800;
      icon = Icons.check_circle;
    } else if (shouldShowError) {
      backgroundColor = const Color(0xFFFFEBEE);
      iconColor = Colors.red;
      titleColor = Colors.red.shade800;
      icon = Icons.error;
    } else {
      backgroundColor = const Color(0xFFE3F2FD);
      iconColor = const Color(0xFF5865F2);
      titleColor = const Color(0xFF1A237E);
      icon = Icons.info;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: iconColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5865F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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

  static void showSuccess(BuildContext context, String message) {
    showAlert(context, "Success", message, isSuccess: true);
  }

  static void showError(BuildContext context, String message) {
    showAlert(context, "Error", message, isError: true);
  }

  static void showInfo(BuildContext context, String title, String message) {
    showAlert(context, title, message);
  }
}
