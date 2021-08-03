import 'package:flutter/material.dart';
import 'package:thesis/services/auth_service.dart';
import 'main_drawer.dart';


class HomePage extends StatelessWidget{
  @override
  Widget build( BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gra geolokalizacyjna"),
      ),
      drawer: MainDrawer(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Strona domowa",
              style: TextStyle(fontSize: 50),
            ),
            ElevatedButton(
              child: AuthService.userIsAuthorized ? const Text('Mapa') : const Text('Zaloguj się'),
              onPressed: (){
                AuthService.userIsAuthorized ?
                  Navigator.of(context).pushNamed('/map')
                  : Navigator.of(context).pushNamed('/login');
              },
            )
          ],
        ),
      ),
    );
  }
}