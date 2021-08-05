import 'package:flutter/material.dart';
import 'main_drawer.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Gra geolokalizacyjna"),
        ),
        drawer: MainDrawer(),
        body: Image.asset('assets/images/home.png',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.fill)
    );
  }
}