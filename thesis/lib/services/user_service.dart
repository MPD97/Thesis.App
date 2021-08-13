import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class UserService {
  UserService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static UserService? _instance;

  static UserService getInstance() {
    return _instance!;
  }

  static Future<UserService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("USER SERVICE: CREATING INSTANCE");
    _instance = UserService._create();
    return _instance!;
  }

  Future<http.Response> getUserDetailsRequest(String userId) async {
    final Uri _getUserDetailsUrl = Uri.parse('$_baseUrl/users/$userId');
    var response = await http.get(_getUserDetailsUrl);
    return response;
  }

  Future<http.Response?> lockUserRequest(String userId, String reason) async {
    if (AuthService.userIsAuthorized == false) {
      print("User not authenticated!");
      return null;
    }
    final Uri _getUserDetailsUrl = Uri.parse('$_baseUrl/users/$userId/lock');
    var response = await http
        .put(_getUserDetailsUrl,
            encoding: Encoding.getByName('utf-8'),
            headers: {"authorization": "Bearer ${AuthService.accessToken}"},
            body: jsonEncode({
              'reason': reason,
            }));
    return response;
  }
}
