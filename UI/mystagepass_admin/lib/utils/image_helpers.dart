import 'dart:convert';

import 'package:flutter/material.dart';

class ImageHelpers {
  static Widget getImage(
    String? image, {
    double height = 40,
    double width = 40,
  }) {
    if (image == null || image.trim().isEmpty) {
      return Image.asset(
        "assets/images/NoProfileImage.png",
        height: height,
        width: width,
      );
    }

    try {
      return Image.memory(base64Decode(image), height: height, width: width);
    } catch (e) {
      print('Error decoding image: $e');
      return Image.asset(
        "assets/images/NoProfileImage.png",
        height: height,
        width: width,
      );
    }
  }
}
