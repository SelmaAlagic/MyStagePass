import 'package:flutter/material.dart';

class AlertHelpers {
  static Future<void> showAlert(
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

    return showDialog(
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

  static void showConfirmationAlert(
    BuildContext context,
    String title,
    String message, {
    required String confirmButtonText,
    required String cancelButtonText,
    required VoidCallback onConfirm,
    bool isDelete = false,
    String? highlightText,
  }) {
    Color backgroundColor;
    Color iconColor;
    Color titleColor;
    Color confirmButtonColor;
    IconData icon;

    if (isDelete) {
      backgroundColor = const Color(0xFFFFEBEE);
      iconColor = Colors.red;
      titleColor = Colors.red.shade800;
      confirmButtonColor = Colors.red;
      icon = Icons.warning_rounded;
    } else {
      backgroundColor = const Color(0xFFFFF8E1);
      iconColor = Colors.orange;
      titleColor = Colors.orange.shade800;
      confirmButtonColor = Colors.green;
      icon = Icons.help_outline;
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: iconColor, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: highlightText != null
                    ? RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: message.split(highlightText)[0]),
                            TextSpan(
                              text: highlightText,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade900,
                                height: 1.5,
                              ),
                            ),
                            if (message.split(highlightText).length > 1)
                              TextSpan(text: message.split(highlightText)[1]),
                          ],
                        ),
                      )
                    : Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color.fromARGB(
                            255,
                            67,
                            69,
                            85,
                          ),
                          side: const BorderSide(
                            color: Color.fromARGB(255, 151, 155, 186),
                            width: 1,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(80, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          cancelButtonText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: confirmButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: const Size(80, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          confirmButtonText,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> showSuccess(BuildContext context, String message) {
    return showAlert(context, "Success", message, isSuccess: true);
  }

  static Future<void> showError(BuildContext context, String message) {
    return showAlert(context, "Error", message, isError: true);
  }

  static Future<void> showInfo(
    BuildContext context,
    String title,
    String message,
  ) {
    return showAlert(context, title, message);
  }
}
