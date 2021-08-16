import 'dart:convert';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/models/UserMeModel.dart';
import 'package:thesis/screens/page_route_generator.dart';
import 'package:thesis/services/auth_service.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  checkPermissions();

  await AuthService.create();

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

      return await _getMeAsUser();
    } else {
      AuthService.refreshToken = "";
      print("Token was not refreshed. Status code: $statusCode ");
      return false;
    }
  }
  print("Token is not need to be refreshed.");
  return true;
}

Future<bool> _getMeAsUser() async {
  final _authService = AuthService.getInstance();
  var response = await _authService.userMeRequest();
  if (response == null) {
    return false;
  }

  if (response.statusCode == 200) {
    UserMeModel model = UserMeModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    var state = model.state;
    if (state == 'valid') {
      return true;
    } else if (state == 'incomplete') {
      return true;
    } else if (state == 'locked') {
      _authService.logOut();
      return false;
    } else {
      _authService.logOut();
      return false;
    }
  }else if (response.statusCode == 404) {
    _authService.logOut();
    return false;
  }else {
    _authService.logOut();
    return false;
  }
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
          primaryColor: AppColors.LIGHT,
          fontFamily: 'Montserrat'
        ),
        initialRoute: '/',
        onGenerateRoute: RouteGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
      designSize: const Size(360, 640),
    );
  }
}
