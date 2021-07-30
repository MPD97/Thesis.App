import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/services/auth_service.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _authService = AuthService.getInstance();
  bool _isLoading = false;

  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://www.codeproject.com/KB/GDI-plus/ImageProcessing2/img.jpg'),
                          fit: BoxFit.fill)),
                ),
                Text(
                    AuthService.pseudonym == ""
                        ? "użytkownik niezalogowany"
                        : AuthService.pseudonym,
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                Text(AuthService.email, style: TextStyle(color: Colors.white))
              ],
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Mapa', style: TextStyle(fontSize: 18)),
          onTap: null,
        ),
        ListTile(
          leading: Icon(Icons.leaderboard),
          title: Text('Ranking', style: TextStyle(fontSize: 18)),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.of(context).pushNamed('/map');
          },
        ),
        ListTile(
          leading: AuthService.userIsAuthorized
              ? Icon(Icons.perm_identity)
              : Icon(Icons.login),
          title: Text(AuthService.userIsAuthorized ? "Moje konto" : "Logowanie",
              style: TextStyle(fontSize: 18)),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            if (AuthService.userIsAuthorized) {
              Navigator.of(context).pushNamed('/me');
            } else {
              Navigator.of(context).pushNamed('/login');
            }
          },
        ),
        ListTile(
          leading: AuthService.userIsAuthorized
              ? Icon(Icons.logout)
              : Icon(Icons.add),
          title: Text(AuthService.userIsAuthorized ? "Wyloguj" : "Rejestracja",
              style: TextStyle(fontSize: 18)),
          onTap: () {
            if (AuthService.userIsAuthorized) {
              _authService.logOut();
              setState(() {});
            } else {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              Navigator.of(context).pushNamed('/register');
            }
          },
        ),
      ],
    ));
  }
}
