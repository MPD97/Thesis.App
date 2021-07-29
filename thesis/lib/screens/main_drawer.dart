import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thesis/services/auth_service.dart';


class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}
class _MainDrawerState extends State<MainDrawer> {
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
                Text(AuthService.pseudonym == "" ? "użytkownik niezalogowany" : AuthService.pseudonym,
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
          onTap: null,
        ),
        ListTile(
          leading: Icon(Icons.arrow_forward),
          title: Text('Logowanie', style: TextStyle(fontSize: 18)),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.of(context).pushNamed('/login');
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Rejestracja', style: TextStyle(fontSize: 18)),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.of(context).pushNamed('/register');
          },
        ),
      ],
    ));
  }
}
