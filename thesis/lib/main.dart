import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/screens/route_generator.dart';
import 'package:thesis/services/auth_service.dart';
import 'screens/main_drawer.dart';
import 'package:workmanager/workmanager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(
      callbackDispatcherPerodic, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
  );
  Workmanager().registerOneOffTask(
    "Workmanager-Refresh_Token_Start",
    "Refresh_Token",
    constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false
    )
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
  runApp(MyApp());
}

void callbackDispatcherPerodic() {
  Workmanager().executeTask((task, inputData) async{
    print("PERODIC");
    var _authInstance = await AuthService.getInstance();
    if(_authInstance.isTokenValidForRefresh() == false){
      print("Token need to be refreshed!");
      var refreshResponse = await _authInstance.refreshTokenRequest();
      if (refreshResponse.statusCode == 200){
        print("Token has been refreshed.");
        return true;
      }else{
        print("Token was not refreshed.");
        return false;
      }
    }
    print("Token is not need to be refreshed.");
    return true;
  });
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

class HomePage extends StatelessWidget{
  @override
  Widget build( BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("Gra geolokalizacyjna"),
      ),
      drawer: MainDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Strona domowa",
              style: TextStyle(fontSize: 50),
            ),
            ElevatedButton(
              child: Text('Go to login'),
              onPressed: (){
                Navigator.of(context).pushNamed('/login');
              },
            )
          ],
        ),
      ),
    );
  }
  Future<bool> isAuthorized() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var accessToken = sharedPreferences.get('accessToken');
    var refreshToken = sharedPreferences.get('refreshToken');
    var expires = sharedPreferences.get('expires');
    var email = sharedPreferences.get('email');
    var pseudonym = sharedPreferences.get('pseudonym');

    if(expires != null){
      var expiresAt = int.parse(expires.toString());
      var now = new DateTime.now().millisecondsSinceEpoch / 1000;

      if(expiresAt < now){
        print("You have to refresh token!");
      }
    }

    return true;
  }
}
