import 'package:flutter/material.dart';
import 'package:thesis/services/auth_service.dart';

class MainDrawer extends StatefulWidget {
  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  final AuthService _authService = AuthService.getInstance();

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(top: 30),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(
                              'https://www.marinasmediterraneo.com/marinaseste/wp-content/uploads/sites/4/2018/09/generic-user-purple-4.png'),
                          fit: BoxFit.fill)
                  ),
                ),
                Text(
                    AuthService.userIsAuthorized == true
                        ? AuthService.pseudonym! == ""
                            ? "brak pseudonimu"
                            : AuthService.pseudonym!
                        : "użytkownik niezalogowany",
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                Text(
                    AuthService.userIsAuthorized == true
                        ? AuthService.email! == ""
                            ? "brak email"
                            : AuthService.email!
                        : "",
                    style: const TextStyle(color: Colors.white))
              ],
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.map),
          title: const Text('Mapa', style: TextStyle(fontSize: 18)),
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            Navigator.of(context).pushNamed('/map');
          },
        ),
        AuthService.userIsAuthorized && AuthService.isUserAdmin()
            ? ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Zarządzaj nowymi trasami', style: TextStyle(fontSize: 18)),
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  Navigator.of(context).pushNamed('/route/show/new');
                },
              )
            : const SizedBox.shrink(),
        const ListTile(
          leading: Icon(Icons.leaderboard),
          title: Text('Ranking', style: TextStyle(fontSize: 18)),
          onTap: null,
        ),
        ListTile(
          leading: AuthService.userIsAuthorized
              ? const Icon(Icons.perm_identity)
              : const Icon(Icons.login),
          title: Text(AuthService.userIsAuthorized ? "Moje konto" : "Logowanie",
              style: const TextStyle(fontSize: 18)),
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
              ? const Icon(Icons.logout)
              : const Icon(Icons.add),
          title: Text(AuthService.userIsAuthorized ? "Wyloguj" : "Rejestracja",
              style: const TextStyle(fontSize: 18)),
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
