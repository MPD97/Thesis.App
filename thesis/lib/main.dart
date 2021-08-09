import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:thesis/screens/page_route_generator.dart';
import 'package:thesis/services/achievement_service.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/comments_service.dart';
import 'package:thesis/services/localisation_service.dart';
import 'package:thesis/services/route_service.dart';
import 'package:thesis/services/run_service.dart';
import 'package:thesis/services/score_service.dart';
import 'package:thesis/services/user_service.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  checkPermissions();

  await AuthService.create();
  await LocalisationService.create();
  await RouteService.create();
  await RunService.create();
  await ScoreService.create();
  await AchievementService.create();
  await UserService.create();
  await CommentsService.create();

  await TryRefreshToken();
  runApp(Application());
}

Future<void> checkPermissions() async {
  if (!kIsWeb) {
    final location = Location();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.granted) {
      await location.requestPermission();
    }
  }
}

Future<bool> TryRefreshToken() async {
  var _authInstance = await AuthService.create();

  if (AuthService.isTokenShouldBeRefreshed()) {
    print("Token should be refreshed!");
    if (AuthService.isTokenAvailableToRefresh() == false) {
      print("Token cannot be refreshed!");
      return true;
    }
    var refreshResponse = await _authInstance.refreshTokenRequest();
    var statusCode = refreshResponse.statusCode;
    if (statusCode == 200) {
      print("Token has been refreshed.");
      return true;
    } else {
      AuthService.refreshToken = "";
      print("Token was not refreshed. Status code: $statusCode ");
      return false;
    }
  }
  print("Token is not need to be refreshed.");
  return true;
}

class Application extends StatefulWidget {
  static const ACCESS_TOKEN =
      "pk.eyJ1IjoibXBkOTciLCJhIjoiY2twNzdheDNiMTM5bTJvczFvb3FvMDZjciJ9.SsZFQE9EsGcgE5l8_etrlw";

  @override
  State<StatefulWidget> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  var authInstance = AuthService.getInstance();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    int status = await BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: true,
            enableHeadless: false,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      print("[BackgroundTokenRefresh] Event received $taskId");

      await TryRefreshToken();

      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      print("[BackgroundTokenRefresh] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    });
    print('[BackgroundTokenRefresh] configure success: $status');

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: () => MaterialApp(
        title: 'Gra geolokalizacyjna',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Montserrat'
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
      designSize: const Size(360, 640),
    );
  }
}
