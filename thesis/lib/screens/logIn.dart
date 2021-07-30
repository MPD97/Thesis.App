import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/helpers/helper.dart';

class LogInPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LogInPage> {
  final AuthService _authService = AuthService.getInstance();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color(0xFF629DDC),
                Color(0xFF4876B4),
                Color(0xFF6097BB)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : ListView(
          children: <Widget>[
            headerSection(),
            textSection(),
            buttonSection(),
          ],
        ),
      ),
    );
  }

  Future<void> signIn(String email, password) async {
    setState(() {_isLoading = true;});
    var response = await _authService.loginRequest(email, password);
    setState(() {_isLoading = false;});

    if(response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if(jsonResponse != null) {
        Helper.toastSuccess("Zalogowano");
        await GetMeAsUser();
      }
    }
    else if(response.statusCode == 400){
      Helper.toastFail("Niepoprawne dane logowania");
    }
    else{
      var jsonResponse = json.decode(response.body);
      Helper.toastFail(jsonResponse['message']);
      print(jsonResponse);
    }
  }

  Future<void> GetMeAsUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {_isLoading = true; });
    var response = await _authService.userMeRequest();
    setState(() {_isLoading = false; });

    await checkResponseAuthorization(response);

    if(response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var state = jsonResponse['state'];
      if(state == 'valid'){
        print("User state is valid");
        Navigator.of(context).pushNamed('/');
      }
      else if(state == 'incomplete'){
        Navigator.of(context).pushNamed('/complete-registration-process');
        print("User state is incomplete");
      }
      else if(state == 'locked'){
        Helper.toastFail("Konto zostało zablokowane.");
        Navigator.of(context).pushNamed('/login');
      }
      else {
        Helper.toastFail("Konto posiada nieznany status.");
        Navigator.of(context).pushNamed('/login');
      }
    }
    else{
      print(response.body);
      var jsonResponse = json.decode(response.body);
      Helper.toastFail(jsonResponse['message']);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: emailController.text == "" ? null : () {
          signIn(emailController.text, passwordController.text);
        },
        child: Text("Zaloguj się", style: TextStyle(color: Colors.white70)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Email",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Hasło",
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Logowanie",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }

  Future<http.Response> checkResponseAuthorization(http.Response response) async{
    var sharedPreferences = await SharedPreferences.getInstance();

    if(response.statusCode == 401){
      await ensureAuthorized();
    }
    return response;
  }

  Future<void> ensureAuthorized() async{
    if(await AuthService.isTokenAvailableToRefresh()){
      if(await AuthService.isTokenValid() == false) {
        await _authService.refreshTokenRequest();
        if(await AuthService.isTokenValid() == false) {
          Navigator.of(context).pushNamed('/login');
        }
      }
      else{
        Navigator.of(context).pushNamed('/login');
      }
    }
    else{
      Navigator.of(context).pushNamed('/login');
    }
  }
}