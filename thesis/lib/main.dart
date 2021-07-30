import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:thesis/screens/route_generator.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
      taskRefreshToken, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  Workmanager().registerPeriodicTask(
    "Workmanager-Refresh_Token",
    "Refresh_Token",
    frequency: const Duration(minutes: 15),
    constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false
    )
  );
  TryRefreshToken();
  checkPermissions();
  runApp(MyApp());
}
Future<void> checkPermissions() async{
  if (!kIsWeb) {
    final location = Location();
    final hasPermissions = await location.hasPermission();
    if (hasPermissions != PermissionStatus.granted) {
      await location.requestPermission();
    }
  }
}
void taskRefreshToken() {
  Workmanager().executeTask((task, inputData) async{
    print("PERODIC");
    return await TryRefreshToken();
  });
}
Future<bool> TryRefreshToken() async{
  var _authInstance = await AuthService.create();
  if(AuthService.isTokenShouldBeRefreshed() == false){
    print("Token should be refreshed!");
    if(AuthService.isTokenAvailableToRefresh() == false){
      print("Token cannot be refreshed!");
      return true;
    }
    var refreshResponse = await _authInstance.refreshTokenRequest();
    var statusCode = refreshResponse.statusCode;
    if (statusCode == 200){
      print("Token has been refreshed.");
      return true;
    }else{
      print("Token was not refreshed. Status code: $statusCode ");
      return false;
    }
  }
  print("Token is not need to be refreshed.");
  return true;
}

class MyApp extends StatefulWidget {
  @override
 State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  var authInstance = AuthService.create();

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Thesis App',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

