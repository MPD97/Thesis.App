import 'package:flutter/material.dart';
import 'main_drawer.dart';


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
}