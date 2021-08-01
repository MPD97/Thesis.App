import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/localisation_service.dart';


class LocalisationService {
  LocalisationService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _addLocationUrl = Uri.parse('$_baseUrl/locations');

  static LocalisationService? _instance = null;
  static SharedPreferences? _sharedPreferences = null;

  static bool locationEnabled = false;

  static LocalisationService getInstance() {
    return _instance!;
  }

  static Future<LocalisationService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("LOCALISATION SERVICE: CREATING INSTANCE");
    _instance = LocalisationService._create();
    _sharedPreferences = await SharedPreferences.getInstance();
    return _instance!;
  }

  static void setLocation(bool enabled){
    print ("Localisation set to: $enabled");
    locationEnabled = enabled;
  }

  void addLocationRequest(LocationData location) {
    if(locationEnabled == false){
      return;
    }

    if(AuthService.userIsAuthorized == false){
      print("User not authentitacted!");
      Helper.toastFail("Nie jesteś zalogowany!");
      return;
    }

    double latitude = location.latitude!;
    double longitude = location.longitude!;
    int accuracy = location.accuracy!.toInt();
    String accessToken = AuthService.accessToken;

    print("POST Lat: ${latitude} Lon: ${longitude} Acc: ${accuracy}");
    var response = http.post(_addLocationUrl,
        headers: {"authorization": "Bearer $accessToken"},
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy
        })
    );
  }
}