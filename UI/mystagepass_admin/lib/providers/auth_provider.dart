import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/Auth/login_response.dart';
import '../utils/authorization.dart';

class AuthProvider with ChangeNotifier {
  static String? _baseUrl;
  final String _endpoint = "api/User/login";
  final _storage = const FlutterSecureStorage();

  AuthProvider() {
    _baseUrl = const String.fromEnvironment(
      "baseUrl",
      defaultValue: "http://localhost:5080/",
    );
  }

  Future<LoginResponse> login() async {
    var url = "$_baseUrl$_endpoint";
    var uri = Uri.parse(url);

    var body = {
      "username": Authorization.username,
      "password": Authorization.password,
    };
    var headers = await createHeaders();
    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (isValidResponse(response)) {
      var data = LoginResponse.fromJson(jsonDecode(response.body));
      if (data.result == 0 && data.token != null) {
        await _storage.write(key: "jwt", value: data.token);

        try {
          Map<String, dynamic> decodedToken = JwtDecoder.decode(data.token!);

          String? userId =
              decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier']
                  ?.toString();
          String? email =
              decodedToken['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress']
                  ?.toString();
          String? firstName = decodedToken['FirstName']?.toString();
          String? lastName = decodedToken['LastName']?.toString();
          String? username = decodedToken['Username']?.toString();

          if (userId != null) {
            await _storage.write(key: "userId", value: userId);
          }
          if (email != null) {
            await _storage.write(key: "email", value: email);
          }
          if (firstName != null) {
            await _storage.write(key: "firstName", value: firstName);
          }
          if (lastName != null) {
            await _storage.write(key: "lastName", value: lastName);
          }
          if (username != null) {
            await _storage.write(key: "username", value: username);
          }
        } catch (e) {
          print("Error decoding JWT: $e");
        }
      }
      return data;
    } else {
      throw Exception("Unknown error");
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    notifyListeners();
  }

  Future<int?> getCurrentUserId() async {
    String? userIdStr = await _storage.read(key: "userId");
    if (userIdStr != null) {
      return int.tryParse(userIdStr);
    }
    return null;
  }

  Future<String?> getCurrentUserFirstName() async {
    return await _storage.read(key: "firstName");
  }

  Future<String?> getCurrentUserLastName() async {
    return await _storage.read(key: "lastName");
  }

  Future<String?> getCurrentUserEmail() async {
    return await _storage.read(key: "email");
  }

  Future<String?> getCurrentUsername() async {
    return await _storage.read(key: "username");
  }

  Future<String?> getCurrentUserFullName() async {
    String? firstName = await getCurrentUserFirstName();
    String? lastName = await getCurrentUserLastName();

    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    }
    return null;
  }

  bool isValidResponse(Response response) {
    if (response.statusCode < 299) {
      return true;
    } else if (response.statusCode == 401) {
      throw Exception("Unauthorized");
    } else {
      throw Exception(
        "${response.statusCode} Something bad happened, please try again later.",
      );
    }
  }

  Future<Map<String, String>> createHeaders() async {
    String token = await _storage.read(key: "jwt") ?? "";
    String bearerAuth = "Bearer $token";
    var headers = {
      "Content-Type": "application/json",
      "Authorization": bearerAuth,
    };

    return headers;
  }
}
