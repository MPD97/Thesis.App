import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';


class LocalisationService {
  LocalisationService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _addLocationUrl = Uri.parse('$_baseUrl/locations');

  static LocalisationService? _instance;

  static bool locationEnabled = false;
  static int _lastLocationSendDate = 0;
  static LocalisationService getInstance() {
    return _instance!;
  }

  static Future<LocalisationService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("LOCALISATION SERVICE: CREATING INSTANCE");
    _instance = LocalisationService._create();
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

    var now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if(_lastLocationSendDate >= now + 1){
      print("Wait 1 sec");
      return;
    }
    _lastLocationSendDate = now;

    double latitude = location.latitude!;
    double longitude = location.longitude!;
    int accuracy = location.accuracy!.toInt();
    String accessToken = AuthService.accessToken!;

    print("POST Lat: $latitude Lon: $longitude Acc: $accuracy");
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