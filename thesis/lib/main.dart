import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/screens/route_generator.dart';
import 'package:thesis/services/auth_service.dart';
import 'screens/main_drawer.dart';

 main() {
  runApp(MyApp());
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
