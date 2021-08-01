import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:thesis/screens/route_generator.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/localisation_service.dart';
import 'package:thesis/services/route_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  var authInstance = await AuthService.create();
  var _localisationService = await LocalisationService.create();
  var _routeService = await RouteService.create();

  Workmanager().initialize(
      taskRefreshToken, // The top level function, aka callbackDispatcher
      isInDebugMode: false
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
  await TryRefreshToken();
  await checkPermissions();
  runApp(Application());
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

  if(AuthService.isTokenShouldBeRefreshed()){
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

class Application extends StatefulWidget {
  static const String ACCESS_TOKEN = "pk.eyJ1IjoibXBkOTciLCJhIjoiY2twNzdheDNiMTM5bTJvczFvb3FvMDZjciJ9.SsZFQE9EsGcgE5l8_etrlw";
  @override
 State<StatefulWidget> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application>{
  var authInstance = AuthService.getInstance();

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

