import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/Auth/login_response.dart';
import '../models/User/user.dart';
import '../utils/authorization.dart';

class AuthProvider with ChangeNotifier {
  static String? _baseUrl;
  final String _loginEndpoint = "api/User/login";
  final String _currentEndpoint = "api/User/current";
  final _storage = const FlutterSecureStorage();

  User? _currentUser;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://10.0.2.2:5080/",
    );
  }

  Future<LoginResponse> login() async {
    var url = "$_baseUrl$_loginEndpoint";
    var body = {
      "username": Authorization.username,
      "password": Authorization.password,
    };

    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (isValidResponse(response)) {
      var data = LoginResponse.fromJson(jsonDecode(response.body));

      if (data.result == 0 && data.token != null) {
        await _storage.write(key: "jwt", value: data.token);
        await fetchCurrentUser();
      }
      return data;
    } else {
      throw Exception("Login failed");
    }
  }

  Future<void> fetchCurrentUser() async {
    var url = "$_baseUrl$_currentEndpoint";
    var headers = await createHeaders();

    try {
      var response = await http.get(Uri.parse(url), headers: headers);

      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        _currentUser = User.fromJson(data);

        if (_currentUser?.role != null) {
          await _storage.write(key: "role", value: _currentUser!.role);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching current user: $e");
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    _currentUser = null;
    notifyListeners();
  }

  bool isValidResponse(http.Response response) {
    if (response.statusCode < 299) return true;
    if (response.statusCode == 401) throw Exception("Unauthorized");
    throw Exception("${response.statusCode}: Error occurred.");
  }

  Future<Map<String, String>> createHeaders() async {
    String token = await _storage.read(key: "jwt") ?? "";
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
}
