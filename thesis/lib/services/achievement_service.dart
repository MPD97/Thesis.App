import 'package:http/http.dart' as http;

class AchievementService {
  AchievementService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';

  static AchievementService? _instance;

  static AchievementService getInstance() {
    if(_instance == null){
      return _createInstance();
    }
    return _instance!;
  }

  static AchievementService _createInstance() {
    print("ACHIEVEMENT SERVICE: CREATING INSTANCE");
    _instance = AchievementService._create();
    return _instance!;
  }

  Future<http.Response?> getAchievementsRequest(String userId) async {
    final Uri _getScore = Uri.parse('$_baseUrl/achievements/$userId');
    var response = await http.get(_getScore);
    return response;
  }
}
