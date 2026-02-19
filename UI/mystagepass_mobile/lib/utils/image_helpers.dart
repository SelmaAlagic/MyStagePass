import 'dart:convert';
import 'dart:typed_data';
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
      return Image.memory(
        base64Decode(image),
        height: height,
        width: width,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } catch (e) {
      return Image.asset(
        "assets/images/NoProfileImage.png",
        height: height,
        width: width,
      );
    }
  }

  static Widget getImageFromBytes(
    Uint8List? bytes, {
    double height = 40,
    double width = 40,
  }) {
    if (bytes == null) {
      return Image.asset(
        "assets/images/NoProfileImage.png",
        height: height,
        width: width,
      );
    }

    return Image.memory(
      bytes,
      height: height,
      width: width,
      fit: BoxFit.cover,
      gaplessPlayback: true,
    );
  }
}
