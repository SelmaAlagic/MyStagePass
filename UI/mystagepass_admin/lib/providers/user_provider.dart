import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/User/user.dart';
import 'base_provider.dart';

class UserProvider extends BaseProvider<User> {
  static const String _userEndpoint = "api/User";

  UserProvider() : super(_userEndpoint);

  @override
  User fromJson(data) {
    return User.fromJson(data);
  }

  Future<User> deactivate(int id) async {
    final url = Uri.parse('${getBaseUrl()}$_userEndpoint/deactivate/$id');
    final headers = await createHeaders();

    final response = await http.delete(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception('Failed to deactivate user: ${response.statusCode}');
    }
  }

  Future<User> restore(int id) async {
    final url = Uri.parse('${getBaseUrl()}$_userEndpoint/restore/$id');
    final headers = await createHeaders();

    final response = await http.put(url, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception('Failed to restore user: ${response.statusCode}');
    }
  }
}
