import 'package:flutter/material.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/screens/map.dart';
import 'package:thesis/screens/route_manage_state.dart';
import 'package:thesis/screens/route_manage_state_details.dart';
import 'package:thesis/screens/user_login.dart';
import 'package:thesis/screens/user_register.dart';
import 'package:thesis/screens/route_add.dart';
import 'package:thesis/screens/route_details.dart';
import 'package:thesis/screens/user_complete.dart';

import 'home.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/login':
        return MaterialPageRoute(builder: (_) => LogInPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterPage());
      case '/complete-registration-process':
        return MaterialPageRoute(
            builder: (_) => CompleteRegistrationProcessPage());
      case '/me':
        return MaterialPageRoute(builder: (_) => HomePage());
      case '/map':
        return MaterialPageRoute(builder: (_) => MapUiPage());
      case '/route/add' :
        if(args is List<LocationModel>){
          return MaterialPageRoute(builder: (_) => RouteAdd(args));
        }
        return _errorRoute();
      case '/route/details':
        if(args is RouteModel){
          return MaterialPageRoute(builder: (_) => RouteDetails(args));
        }
        return _errorRoute();
      case '/route/show/new':
        return MaterialPageRoute(builder: (_) => RouteAccept());
      case '/route/show/new/details':
        if(args is RouteModel) {
          return MaterialPageRoute(builder: (_) => RouteAcceptDetails(args));
        }
        return _errorRoute();
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Błąd routingu"),
        ),
        body: Center(
          child: Text('BŁĄD'),
        ),
      );
    });
  }
}
