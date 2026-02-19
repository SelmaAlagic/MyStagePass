import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/Auth/login_response.dart';
import '../models/User/user.dart';
import '../utils/authorization.dart';

class AuthProvider with ChangeNotifier {
  static String? _baseUrl;
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? currentUserInfo;
  User? currentUser;
  Uint8List? profileImageBytes;

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://10.0.2.2:5080/",
    );
  }

  Future<LoginResponse> login() async {
    var url = "${_baseUrl}api/User/login";
    var body = {
      "username": Authorization.username,
      "password": Authorization.password,
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode < 299) {
      var data = LoginResponse.fromJson(jsonDecode(response.body));
      if (data.token != null) {
        await _storage.write(key: "jwt", value: data.token);
      }
      return data;
    } else {
      try {
        var errorData = jsonDecode(response.body);
        String serverMessage = errorData['message'] ?? "Login failed";
        throw Exception(serverMessage);
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception("Server error (${response.statusCode})");
      }
    }
  }

  Future<void> fetchCurrentUserInfo() async {
    if (currentUserInfo != null) return;

    var url = "${_baseUrl}api/User/current";
    var headers = await _createHeaders();

    var response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode < 299) {
      currentUserInfo = jsonDecode(response.body);
      notifyListeners();
    }
  }

  Future<void> fetchMyProfile() async {
    if (currentUser != null) return;

    var url = "${_baseUrl}api/User/my-profile";
    var headers = await _createHeaders();

    var response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode < 299) {
      currentUser = User.fromJson(jsonDecode(response.body));
      if (currentUser?.image != null && currentUser!.image!.isNotEmpty) {
        try {
          profileImageBytes = base64Decode(currentUser!.image!);
        } catch (_) {}
      }
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    currentUserInfo = null;
    currentUser = null;
    profileImageBytes = null;
    Authorization.username = null;
    Authorization.password = null;
    notifyListeners();
  }

  Future<Map<String, String>> _createHeaders() async {
    String token = await _storage.read(key: "jwt") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}
