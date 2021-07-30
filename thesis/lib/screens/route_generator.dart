import 'package:flutter/material.dart';
import 'package:thesis/main.dart';
import 'package:thesis/screens/logIn.dart';
import 'package:thesis/screens/register.dart';

import 'complete_registration_process.dart';

class RouteGenerator{
  static Route<dynamic> generateRoute(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LogInPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/complete-registration-process':
        return MaterialPageRoute(builder: (_) => CompleteRegistrationProcessPage());
      case '/me':
        return MaterialPageRoute(builder: (_) => CompleteRegistrationProcessPage());
      
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: Text("Błąd"),
        ),
        body: Center(
          child: Text('BŁĄD'),
        ),
      );
    });
  }
}