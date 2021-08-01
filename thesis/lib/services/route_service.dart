import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/localisation_service.dart';


class RouteService {
  RouteService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _addRouteUrl = Uri.parse('$_baseUrl/routes');

  static RouteService? _instance = null;

  static RouteService getInstance() {
    return _instance!;
  }

  static Future<RouteService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("ROUTE SERVICE: CREATING INSTANCE");
    _instance = RouteService._create();
    return _instance!;
  }

  Future<dynamic> addRouteRequest(String routeName, String routeDescription,
      String difficulty, int activityType, List<LocationModel> locations) async{

    if(AuthService.userIsAuthorized == false){
      print("User not authentitacted!");
      Helper.toastFail("Nie jesteś zalogowany!");
      return;
    }
    String accessToken = AuthService.accessToken;
    var bodyString = jsonEncode({
      'name': routeName,
      'description': routeDescription,
      'difficulty': difficulty,
      'activityKind': activityType,
      'points': locations
    });
    print(bodyString);
    var response = await http.post(_addRouteUrl,
        headers: { "authorization": "Bearer $accessToken" },
        body: bodyString
    );
    return response;
  }

  Future<http.Response> getRoutesRequest(LatLng southWest, LatLng northEast, String? difficulty, int? activity, bool? onlyAccepted, int page) async{
    final location = '?southWestLatitude=${southWest.latitude}&southWestLongitude=${southWest.longitude}&northEastLatitude=${northEast.latitude}&northEastLongitude=${northEast.longitude}';
    final pagination = '&page=${page.toString()}';
    String properties = "";
    if(onlyAccepted != null){
      properties += '&onlyAccepted=${onlyAccepted}';
    }
    if(activity != null){
      properties += '&activityKind=${activity}';
    }
    if(difficulty != null){
      properties += '&difficulty=${difficulty}';
    }
    final Uri _getRoutesUrl = Uri.parse('$_baseUrl/routes${location}${properties}${pagination}');
    print(_getRoutesUrl);
    var response = await http.get(_getRoutesUrl);
    return response;
  }
}