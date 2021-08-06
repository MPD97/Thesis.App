import 'package:http/http.dart' as http;

class ScoreService {
  ScoreService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';

  static ScoreService? _instance;

  static ScoreService getInstance() {
    return _instance!;
  }

  static Future<ScoreService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("SCORE SERVICE: CREATING INSTANCE");
    _instance = ScoreService._create();
    return _instance!;
  }

  Future<http.Response?> getUserScoreRequest(String userId) async {
    final Uri _getScore = Uri.parse('$_baseUrl/scores/$userId');
    var response = await http.get(_getScore);
    return response;
  }
}
