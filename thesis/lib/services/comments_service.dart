import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';

class CommentsService {
  CommentsService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';
  static final Uri _addCommandUrl = Uri.parse('$_baseUrl/resources');

  static CommentsService? _instance;

  static CommentsService getInstance() {
    if(_instance == null){
      return _createInstance();
    }
    return _instance!;
  }

  static CommentsService _createInstance() {
    print("COMMENTS SERVICE: CREATING INSTANCE");
    _instance = CommentsService._create();
    return _instance!;
  }

  Future<http.Response?> addCommentRequest(
      String routeId, String text) async {
    if (AuthService.userIsAuthorized == false) {
      print("User not authentitacted!");
      Helper.toastFail("Nie jesteś zalogowany!");
      return null;
    }
    String accessToken = AuthService.accessToken!;

    var response = await http.post(_addCommandUrl,
        encoding: Encoding.getByName('utf-8'),
        headers: {"authorization": "Bearer $accessToken"},
        body: jsonEncode({
          'routeId': routeId,
          'text': text,
        }));

    return response;
  }

  Future<http.Response> getCommentsRequest(
      String routeId, int page) async {
    final _routeId = '?routeId=$routeId';
    final _orderSort = '&orderBy=createdAt';
    final _pagination = '&page=${page.toString()}';

    final _url = Uri.parse('$_baseUrl/resources$_routeId$_orderSort$_pagination');
    print(_url);

    final response = await http.get(_url);

    return response;
  }
}
