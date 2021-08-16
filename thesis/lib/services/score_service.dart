import 'package:http/http.dart' as http;

class ScoreService {
  ScoreService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';

  static ScoreService? _instance;

  static ScoreService getInstance() {
    if(_instance == null){
      return _createInstance();
    }
    return _instance!;
  }

  static ScoreService _createInstance() {
    print("SCORE SERVICE: CREATING INSTANCE");
    _instance = ScoreService._create();
    return _instance!;
  }

  Future<http.Response?> getUserScoreRequest(String userId) async {
    final Uri _getScore = Uri.parse('$_baseUrl/scores/$userId');
    var response = await http.get(_getScore);
    return response;
  }

  Future<http.Response> getOverallRankingRequest(int page) async {
    final _orderSort = '?orderBy=score&sortOrder=desc';
    final _pagination = '&page=${page.toString()}';
    final Uri _searchRunsUrl =
    Uri.parse('$_baseUrl/scores$_orderSort$_pagination');
    print(_searchRunsUrl);
    var response = await http.get(_searchRunsUrl);
    return response;
  }

  Future<http.Response?> getUserPlaceInRankingRequest(String userId) async {
    final Uri _getScore = Uri.parse('$_baseUrl/scores/ranking/$userId');
    var response = await http.get(_getScore);
    return response;
  }
}
