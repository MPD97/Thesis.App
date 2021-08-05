import 'package:http/http.dart' as http;

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

  Future<http.Response> getUserDetailsRequest(String userId) async{
    final Uri _getUserDetailsUrl = Uri.parse('$_baseUrl/users/$userId');
    var response = await http.get(_getUserDetailsUrl);
    return response;
  }
}