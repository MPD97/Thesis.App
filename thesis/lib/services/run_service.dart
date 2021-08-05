import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';


class RunService {
  RunService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _addRunUrl = Uri.parse('$_baseUrl/runs');

  static RunService? _instance;

  static RunService getInstance() {
    return _instance!;
  }

  static Future<RunService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("RUN SERVICE: CREATING INSTANCE");
    _instance = RunService._create();
    return _instance!;
  }


  Future<http.Response?> addRunRequest(LocationData location, String routeId) async{
    if(AuthService.userIsAuthorized == false){
      print("User not authentitacted!");
      Helper.toastFail("Nie jesteś zalogowany!");
      return null;
    }

    double latitude = location.latitude!;
    double longitude = location.longitude!;
    int accuracy = location.accuracy!.toInt();
    String accessToken = AuthService.accessToken!;

    var response = await http.post(_addRunUrl,
        headers: {"authorization": "Bearer $accessToken"},
        body: jsonEncode({
          'routeId': routeId,
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy
        })
    );

    return response;
  }

  Future<http.Response> getRunRankingRequest(String routeId, String date, int page) async{

    final _routeId = '?routeId=$routeId';
    final _date = '&date=$date';
    final _orderSort = '&orderBy=time&sortOrder=asc';
    final _pagination = '&page=${page.toString()}';
    final Uri _searchRunsUrl = Uri.parse('$_baseUrl/runs$_routeId$_date$_orderSort$_pagination');

    var response = await http.get(_searchRunsUrl);
    return response;
  }
}