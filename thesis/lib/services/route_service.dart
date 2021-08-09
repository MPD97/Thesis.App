import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/models/RouteStatusModel.dart';
import 'package:thesis/services/auth_service.dart';

class RouteService {
  RouteService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _addRouteUrl = Uri.parse('$_baseUrl/routes');

  static RouteService? _instance;

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

  Future<dynamic> addRouteRequest(
      String routeName,
      String routeDescription,
      String difficulty,
      int activityType,
      List<LocationModel> locations) async {
    if (AuthService.userIsAuthorized == false) {
      print("User not authentitacted!");
      Helper.toastFail("Nie jesteś zalogowany!");
      return;
    }
    String accessToken = AuthService.accessToken!;
    var bodyString = jsonEncode({
      'name': routeName,
      'description': routeDescription,
      'difficulty': difficulty,
      'activityKind': activityType,
      'points': locations
    });
    print(bodyString);
    var response = await http.post(_addRouteUrl,
        encoding: Encoding.getByName('utf-8'),
        headers: {"authorization": "Bearer $accessToken"}, body: bodyString);
    return response;
  }

  Future<http.Response> getRoutesRequest(LatLng southWest, LatLng northEast,
      String? difficulty, int? activity, bool? onlyAccepted, int page) async {
    final _location =
        '?southWestLatitude=${southWest.latitude}&southWestLongitude=${southWest.longitude}&northEastLatitude=${northEast.latitude}&northEastLongitude=${northEast.longitude}';
    final _pagination = '&page=${page.toString()}';
    String _properties = "";
    if (onlyAccepted != null) {
      _properties += '&onlyAccepted=${onlyAccepted}';
    }
    if (activity != null) {
      _properties += '&activityKind=${activity}';
    }
    if (difficulty != null) {
      _properties += '&difficulty=${difficulty}';
    }
    final Uri _getRoutesUrl =
        Uri.parse('$_baseUrl/routes$_location$_properties$_pagination');
    print(_getRoutesUrl);
    var response = await http.get(_getRoutesUrl);
    return response;
  }

  Future<http.Response> getNewRoutesRequest(int page) async {
    const _onlyNew = '?onlyNew=true';
    final _pagination = '&page=${page.toString()}';
    final Uri _getRoutesUrl =
        Uri.parse('$_baseUrl/routes$_onlyNew$_pagination');
    print(_getRoutesUrl);
    var response = await http.get(_getRoutesUrl);
    return response;
  }

  Future<http.Response?> changeRouteStatusRequest(
      String routeId, RouteStatusModel status) async {
    if (AuthService.userIsAuthorized == false) {
      print("User not authentitacted!");
      Helper.toastFail("Nie jesteś zalogowany!");
      return null;
    }

    if (AuthService.isUserAdmin() == false) {
      print("User not in admin role!");
      Helper.toastFail("Nie jesteś administratorem!");
      return null;
    }

    String accessToken = AuthService.accessToken!;

    final Uri _rejectRouteUrl = Uri.parse(
        '$_baseUrl/routes/$routeId/status/${status.toString().split('.').last}');
    print(_rejectRouteUrl);
    var response = await http.put(_rejectRouteUrl,
        encoding: Encoding.getByName('utf-8'),
        headers: {"authorization": "Bearer $accessToken"}, body: "{}");
    return response;
  }
}
