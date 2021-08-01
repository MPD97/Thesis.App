import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/services/auth_service.dart';

import 'main_drawer.dart';


class CompleteRegistrationProcessPage extends StatefulWidget {
  @override
  _CompleteRegistrationProcessPageState createState() => _CompleteRegistrationProcessPageState();
}

class _CompleteRegistrationProcessPageState extends State<CompleteRegistrationProcessPage> {
  final AuthService _authService = AuthService.getInstance();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      drawer: MainDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color(0xFF4170B3),
                Color(0xFF6D9CEC),
                Color(0xFF85F1F5)
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

  completeRegistration(String pseudonym) async {
    setState(() {_isLoading = true;});
    var response = await _authService.completeRegistration(pseudonym);
    setState(() {_isLoading = false;});

    if(response.statusCode == 201) {
      Helper.toastSuccess("Pseudonim zapisany");
      Navigator.of(context).pushNamed('/');
    }
    else if(response.statusCode == 400){
      var jsonResponse = json.decode(response.body);
      switch(jsonResponse['code']){
        case 'user_already_registered':
          Helper.toastFail('Pseudonim jest zajęty');
          break;
        case 'invalid_user_pseudonym_length':
          Helper.toastFail('Pseudonim jest za krótki, lub za długi');
          break;
        default :
          Helper.toastFail('Wystąpił nieznany błąd');
          print(jsonResponse);
          break;
      }
    }
    else{
      var jsonResponse = json.decode(response.body);
      Helper.toastFail(jsonResponse['message']);
      print(jsonResponse);
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: pseudonymController.text == "" ? null : () {
          completeRegistration(pseudonymController.text);
        },
        child: Text("Zapisz", style: TextStyle(color: Colors.white70)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }

  final TextEditingController pseudonymController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: pseudonymController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.tag_faces, color: Colors.white70),
              hintText: "Pseudonim",
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
      child: Text("Wybierz pseudonim",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}