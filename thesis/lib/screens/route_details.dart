import 'package:flutter/material.dart';
import 'package:thesis/models/RouteModel.dart';

class RouteDetails extends StatefulWidget {
  late RouteModel _routeModel;

  RouteDetails(this._routeModel);

  @override
  _RouteDetailsState createState() => _RouteDetailsState(_routeModel);
}

class _RouteDetailsState extends State<RouteDetails> {
  late RouteModel _routeModel;
  
  _RouteDetailsState(this._routeModel);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(_routeModel.name),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: Column(
          children: <Widget>[
            Text("Trasa: ${_routeModel.name}"),
            SizedBox(height: 30.0),
            Text("Opis: ${_routeModel.description}"),
            SizedBox(height: 30.0),
            Text("Poziom trudności: ${_routeModel.difficulty}"),
            SizedBox(height: 30.0),
            Text("Długość trasy: ${_routeModel.length}"),
          ],
        ),
      ),
    );
  }
  
}