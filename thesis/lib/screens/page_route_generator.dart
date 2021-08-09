import 'package:flutter/material.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/screens/map.dart';
import 'package:thesis/screens/route_add.dart';
import 'package:thesis/screens/route_comments.dart';
import 'package:thesis/screens/route_comments_add.dart';
import 'package:thesis/screens/route_details.dart';
import 'package:thesis/screens/route_manage_state.dart';
import 'package:thesis/screens/route_manage_state_details.dart';
import 'package:thesis/screens/route_ranking.dart';
import 'package:thesis/screens/user_complete.dart';
import 'package:thesis/screens/user_details.dart';
import 'package:thesis/screens/user_login.dart';
import 'package:thesis/screens/user_me.dart';
import 'package:thesis/screens/user_ranking.dart';
import 'package:thesis/screens/user_register.dart';
import 'package:thesis/services/auth_service.dart';
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
        if(AuthService.userRegistrationCompleted)
          return MaterialPageRoute(builder: (_) => UserMePage());
        else
          return MaterialPageRoute(builder: (_) => CompleteRegistrationProcessPage());
      case '/map':
        return MaterialPageRoute(builder: (_) => MapUiPage());

      case '/route/add':
        if (args is List<LocationModel>)
          return MaterialPageRoute(builder: (_) => RouteAddPage(args));
        return _errorRoute();

      case '/route/details':
        if (args is RouteModel)
          return MaterialPageRoute(builder: (_) => RouteDetailsPage(args));
        return _errorRoute();

      case '/route/show/new':
        return MaterialPageRoute(builder: (_) => RouteAcceptPage());

      case '/route/show/new/details':
        if (args is RouteModel)
          return MaterialPageRoute(
              builder: (_) => RouteAcceptDetailsPage(args));
        return _errorRoute();

      case '/route/ranking':
        if (args is RouteModel)
          return MaterialPageRoute(builder: (_) => RouteRankingPage(args));
        return _errorRoute();

      case '/route/comments':
        if (args is RouteModel)
          return MaterialPageRoute(builder: (_) => RouteCommentsPage(args));
        return _errorRoute();

      case '/route/comments/add':
        if (args is RouteModel)
          return MaterialPageRoute(builder: (_) => RouteAddCommentPage(args));
        return _errorRoute();

      case '/user':
        if (args is String)
          return MaterialPageRoute(builder: (_) => UserDetailsPage(args));
        return _errorRoute();

      case '/user/ranking':
        return MaterialPageRoute(builder: (_) => UserRankingPage());

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
