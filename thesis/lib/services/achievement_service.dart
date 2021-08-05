import 'package:http/http.dart' as http;
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';


class AchievementService {
  AchievementService._create();

  static const String _baseUrl = 'https://thesisapi.ddns.net';

  static AchievementService? _instance;

  static AchievementService getInstance() {
    return _instance!;
  }

  static Future<AchievementService> create() async {
    if (_instance != null) {
      return _instance!;
    }
    print("ACHIEVEMENT SERVICE: CREATING INSTANCE");
    _instance = AchievementService._create();
    return _instance!;
  }

  Future<http.Response?> getAchievementsRequest(String userId) async{
    final Uri _getScore = Uri.parse('$_baseUrl/achievements/$userId');
    var response = await http.get(_getScore);
    return response;
  }
}