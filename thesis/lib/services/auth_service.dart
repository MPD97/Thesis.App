import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
  AuthService._create();
  final String _baseUrl = 'https://thesisapi.ddns.net';
  static AuthService? _instance = null;

  static SharedPreferences? sharedPreferences = null;
  static var userIsAuthorized = false;
  static var accessToken = "";
  static var refreshToken = "";
  static var pseudonym = "";
  static var role = "";
  static var email = "";
  static var expires = "";
  static var state = "";
  static var meId = "";

  static AuthService getInstance(){
    userIsAuthorized = isTokenValid();
    return _instance!;
  }

  static Future<AuthService> create() async {
    if(_instance != null){
      return _instance!;
    }
    print("AUTH SERVICE: CREATING INSTANCE");
    _instance = AuthService._create();
    sharedPreferences = await SharedPreferences.getInstance();

    accessToken = sharedPreferences!.get("accessToken").toString();
    refreshToken = sharedPreferences!.get("refreshToken").toString();
    pseudonym = sharedPreferences!.get("pseudonym").toString();
    role = sharedPreferences!.get("role").toString();
    email = sharedPreferences!.get("email").toString();
    expires = sharedPreferences!.get("expires").toString();
    state = sharedPreferences!.get("state").toString();
    meId = sharedPreferences!.get("meId").toString();

    return _instance!;
  }

  Future<http.Response> registerUser(String email, String password) async {
    var singUpUrl = Uri.parse('$_baseUrl/identity/sign-up');

    var response = await http.post(singUpUrl,
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'user'
        })
    );

    return response;
  }

  Future<http.Response> loginRequest(String email, String password) async {

    var singInUrl = Uri.parse('$_baseUrl/identity/sign-in');
    var response = await http.post(singInUrl,
      body: jsonEncode({
        'email': email,
        'password': password,
      })
    );
    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);

      setAccessToken(jsonResponse['accessToken']);
      setRefreshToken(jsonResponse['refreshToken']);
      setRole(jsonResponse['role']);
      setExpires(jsonResponse['expires'].toString());
      setEmail(email);
    }

    return response;
  }

  Future<http.Response> userMeRequest() async {
    var accessToken = sharedPreferences!.get('accessToken').toString();

    var userMeUrl = Uri.parse('$_baseUrl/users/me');

    var response = await http.get(userMeUrl,
        headers: {
          'Authorization': 'Bearer $accessToken'
        }
    );
    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);

      setEmail(jsonResponse['email']);
      setPseudonym(jsonResponse['pseudonym']);
      setState(jsonResponse['state']);
      setMeId(jsonResponse['id']);
    }
    return response;
  }

  Future<http.Response> refreshTokenRequest() async {
    var singInUrl = Uri.parse('$_baseUrl/identity/refresh-tokens/use');
    var response = await http.post(singInUrl,
        body: jsonEncode({
          'refreshToken': refreshToken,
        })
    );
    var statusCode = response.statusCode;
    print("Code: $statusCode. Rtoken: $refreshToken");
    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      print("Code: $jsonResponse");
      setAccessToken(jsonResponse['accessToken']);
      setRefreshToken(jsonResponse['refreshToken']);
      setRole(jsonResponse['role']);
      setExpires(jsonResponse['expires'].toString());
    }
    return response;
  }

  Future<http.Response> completeRegistration(String pseudonym) async {
    String accessToken = sharedPreferences!.get('accessToken').toString();

    var singInUrl = Uri.parse('$_baseUrl/users');
    var response = await http.post(singInUrl,
        headers: {"authorization": "Bearer $accessToken"},
        body: jsonEncode({
          'pseudonym': pseudonym,
        })
    );
    if(response.statusCode == 201){
      setPseudonym(pseudonym.toString());
    }
    return response;
  }

  void logOut(){
    setAccessToken("");
    setRefreshToken("");
    setMeId("");
    setEmail("");
    setState("");
    setRole("");
    setExpires("");
    setPseudonym("");
    userIsAuthorized = isTokenValid();
  }

  static bool isTokenShouldBeRefreshed(){
    if(expires != "" && accessToken != ""){
      var expiresAt = int.parse(expires);
      var now = DateTime.now().millisecondsSinceEpoch / 1000;
      var fifteenMinutes = 60 * 15;

      if(expiresAt >= now + fifteenMinutes){
        return true;
      }
    }
    return false;
  }

  static bool isTokenValid(){
    if(expires != "" && accessToken != ""){
      var expiresAt = int.parse(expires);
      var now = DateTime.now().millisecondsSinceEpoch / 1000;

      if(expiresAt >= now){
        print("Token is valid");
        return true;
      }
    }
    return false;
  }

  static bool isTokenAvailableToRefresh(){
    if(refreshToken != ""){
      return true;
    }
    return false;
  }

  setAccessToken(String value){
    accessToken = value;
    sharedPreferences!.setString("accessToken", value);
  }

  setRefreshToken(String value){
    refreshToken = value;
    sharedPreferences!.setString("refreshToken", value);
  }

  setExpires(String value){
    expires = value;
    sharedPreferences!.setString("expires", value);
  }

  setRole(String value){
    role = value;
    sharedPreferences!.setString("role", value);
  }

  setPseudonym(String value){
    pseudonym = value;
    sharedPreferences!.setString("pseudonym", value);
  }

  setEmail(String value){
    email = value;
    sharedPreferences!.setString("email", value);
  }

  setState(String value){
    state = value;
    sharedPreferences!.setString("state", value);
  }

  setMeId(String value){
    meId = value;
    sharedPreferences!.setString("meId", value);
  }
}