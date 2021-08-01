import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/LocationModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:thesis/services/route_service.dart';

import 'main_drawer.dart';

class RouteAdd extends StatefulWidget {
  late List<LocationModel> locations;

  RouteAdd(this.locations);

  @override
  _RouteAddState createState() => _RouteAddState(locations);
}

class _RouteAddState extends State<RouteAdd> {
  late List<LocationModel> _locations;

  _RouteAddState(List<LocationModel> locations) {
    this._locations = locations;
  }

  final AuthService _authService = AuthService.getInstance();
  final RouteService _routeService = RouteService.getInstance();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      appBar: AppBar(
        title: Text("Dodawanie trasy"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF629DDC), Color(0xFF4876B4), Color(0xFF6097BB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: () {
          addRoute();
        },
        child: Text("Dodaj trasę", style: TextStyle(color: Colors.white70)),
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
    );
  }
  Future<void> addRoute() async {
    final String routeName = routeNameController.text;
    final String routeDescription = routeDescriptionController.text;
    String difficulty = dropdownValue;

    switch (dropdownValue){
      case 'Wybierz poziom trudności':
        Helper.toastFail("Wybierz poziom trudności");
        return;
      case "Zielony":
        difficulty = "green";
        break;
      case 'Niebieski':
        difficulty = 'blue';
        break;
      case 'Czerwony':
        difficulty = 'red';
        break;
      case 'Czarny':
        difficulty = 'black';
        break;
      default:
        throw new Exception();
    }
    int activityType = 0;

    for (var element in activityTypesValue) {
      activityType |= int.parse(element.toString());
    }

    setState(() {_isLoading = true;});
    var response = await _routeService.addRouteRequest(routeName, routeDescription, difficulty, activityType, _locations);
    setState(() {_isLoading = false;});

    if(response.statusCode == 201) {
      Helper.toastSuccess("Trasa została dodana i czeka na akceptację");
      Future.delayed(const Duration(milliseconds: 1500), () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pushNamed('/map');
      });
    }
    else if(response.statusCode == 400){
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);

      if(jsonResponse['code'] == 'route_already_exists'){
        Helper.toastFail("Trasa z tą nazwą już istnieje");
      }else if(jsonResponse['code'] == 'route_name_too_short'){
        Helper.toastFail("Nazwa trasy jest za krótka.");
      }
    }
    else{
      Helper.toastFail("Wystąpił nieznany błąd");
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
    }
  }

  final TextEditingController routeNameController = new TextEditingController();
  final TextEditingController routeDescriptionController =  new TextEditingController();
  String dropdownValue = 'Wybierz poziom trudności';
  List<dynamic> activityTypesValue =
      new List<dynamic>.filled(0, null, growable: true);

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: routeNameController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Nazwa trasy",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: routeDescriptionController,
            cursorColor: Colors.white,
            obscureText: true,
            style: TextStyle(color: Colors.white70),
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Opis trasy",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.white70),
            ),
          ),
          SizedBox(height: 30.0),
          DropdownButton<String>(
            isExpanded: true,
            dropdownColor: Colors.black87,
            value: dropdownValue,
            icon: const Icon(Icons.arrow_downward, color: Colors.white70),
            iconSize: 24,
            hint: Text("Poziom trudności"),
            elevation: 16,
            style: const TextStyle(color: Colors.white70),
            underline: Container(
              height: 2,
              color: Colors.white70,
            ),
            onChanged: (String? newValue) {
              setState(() {
                dropdownValue = newValue!;
              });
            },
            items: <String>['Wybierz poziom trudności','Zielony', 'Niebieski', 'Czerwony', 'Czarny']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(fontSize: 24),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 30.0),
          MultiSelectFormField(
            autovalidate: false,
            chipBackGroundColor: Colors.blue,
            chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
            dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
            checkBoxActiveColor: Colors.blue,
            checkBoxCheckColor: Colors.green,
            dialogShapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            title: Text(
              "Rodzaj aktywności",
              style: TextStyle(fontSize: 16),
            ),
            dataSource: [
              {
                "display": "Spacer",
                "value": "1",
              },
              {
                "display": "Hiking",
                "value": "2",
              },
              {
                "display": "Bieganie",
                "value": "4",
              },
              {
                "display": "Jazda rowerem",
                "value": "8",
              },
            ],
            textField: 'display',
            valueField: 'value',
            okButtonLabel: 'ok',
            cancelButtonLabel: 'anuluj',
            hintWidget: Text('Wybierz jedno, lub więcej'),
            initialValue: activityTypesValue,
            onSaved: (value) {
              if (value == null) return;
              setState(() {
                activityTypesValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 15.0),
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      child: Text("Trasa",
          style: TextStyle(
              color: Colors.white70,
              fontSize: 40.0,
              fontWeight: FontWeight.bold)),
    );
  }
}