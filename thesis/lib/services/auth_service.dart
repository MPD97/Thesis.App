import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService{
  AuthService._create();
  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _refreshTokenUri = Uri.parse('$_baseUrl/identity/refresh-tokens/use');
  static final Uri _singUpUrl = Uri.parse('$_baseUrl/identity/sign-up');
  static final Uri _userMeUrl = Uri.parse('$_baseUrl/users/me');
  static final Uri _singInUrl = Uri.parse('$_baseUrl/identity/sign-in');
  static final Uri _completeRegistrationUrl = Uri.parse('$_baseUrl/users');


  static AuthService? _instance;

  static SharedPreferences? _sharedPreferences;
  static var userIsAuthorized = false;
  static var _userIsInAdminRole = false;
  static String? accessToken = "";
  static String? refreshToken = "";
  static String? pseudonym = "";
  static String? role = "";
  static String? email = "";
  static String? expires = "";
  static String? state = "";
  static String? meId = "";

  static AuthService getInstance(){
    userIsAuthorized = isTokenValid();
    return _instance!;
  }

  static Future<AuthService> create() async {
    if(_instance != null){
      return getInstance();
    }
    print("AUTH SERVICE: CREATING INSTANCE");
    _instance = AuthService._create();
    _sharedPreferences = await SharedPreferences.getInstance();

    accessToken = _sharedPreferences!.get("accessToken").toString();
    refreshToken = _sharedPreferences!.get("refreshToken").toString();
    pseudonym = _sharedPreferences!.get("pseudonym").toString();
    role = _sharedPreferences!.get("role").toString();
    email = _sharedPreferences!.get("email").toString();
    expires = _sharedPreferences!.get("expires").toString();
    state = _sharedPreferences!.get("state").toString();
    meId = _sharedPreferences!.get("meId").toString();

    return getInstance();
  }

  Future<http.Response> registerUser(String email, String password) async {
    var response = await http.post(_singUpUrl,
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': 'user'
        })
    );

    return response;
  }

  Future<http.Response> loginRequest(String email, String password) async {
    var response = await http.post(_singInUrl,
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
      userIsAuthorized = isTokenValid();
    }

    return response;
  }

  Future<http.Response> userMeRequest() async {
    var response = await http.get(_userMeUrl,
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
    var response = await http.post(_refreshTokenUri,
        body: jsonEncode({
          'refreshToken': refreshToken,
        })
    );
    if(response.statusCode == 200){
      var jsonResponse = json.decode(response.body);
      setAccessToken(jsonResponse['accessToken']);
      setRefreshToken(jsonResponse['refreshToken']);
      setRole(jsonResponse['role']);
      setExpires(jsonResponse['expires'].toString());
      userIsAuthorized = isTokenValid();
    }
    return response;
  }

  Future<http.Response> completeRegistration(String pseudonym) async {
    var response = await http.post(_completeRegistrationUrl,
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
    if(expires != "null" && expires != "" && accessToken != "null" && accessToken != ""){
      var expiresAt = int.parse(expires!);
      var now = DateTime.now().millisecondsSinceEpoch / 1000;
      var fifteenMinutes = 60 * 15;

      if(expiresAt >= now + fifteenMinutes){
        return false;
      }
    }
    return true;
  }

  static bool isUserAdmin(){
    if(role == 'admin'){
      _userIsInAdminRole = true;
    }else{
      _userIsInAdminRole = false;
    }
    return _userIsInAdminRole;
  }

  static bool isTokenValid(){
    if(expires != "null" && expires != null && expires != "" && accessToken != null && accessToken != ""){
      print("Expiries: $expires");
      var expiresAt = int.parse(expires!);
      var now = DateTime.now().millisecondsSinceEpoch / 1000;

      if(expiresAt >= now){
        return true;
      }else{
        print("Token is outdated");
      }
    }
    print("Token is not valid");
    return false;
  }

  static bool isTokenAvailableToRefresh(){
    if(refreshToken != "null" && refreshToken != ""){
      return true;
    }
    return false;
  }

  setAccessToken(String value){
    accessToken = value;
    _sharedPreferences!.setString("accessToken", value);
  }

  setRefreshToken(String value){
    refreshToken = value;
    _sharedPreferences!.setString("refreshToken", value);
  }

  setExpires(String value){
    expires = value;
    _sharedPreferences!.setString("expires", value);
  }

  setRole(String value){
    role = value;
    _sharedPreferences!.setString("role", value);
    if(role == 'admin'){
      _userIsInAdminRole = true;
    }else{
      _userIsInAdminRole = false;
    }
  }

  setPseudonym(String value){
    pseudonym = value;
    _sharedPreferences!.setString("pseudonym", value);
  }

  setEmail(String value){
    email = value;
    _sharedPreferences!.setString("email", value);
  }

  setState(String value){
    state = value;
    _sharedPreferences!.setString("state", value);
  }

  setMeId(String value){
    meId = value;
    _sharedPreferences!.setString("meId", value);
  }
}