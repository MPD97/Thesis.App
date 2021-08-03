import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/PagedResultModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/models/RouteStatusModel.dart';
import 'package:thesis/services/route_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RouteAccept extends StatefulWidget {
  RouteAccept();

  @override
  _RouteAcceptState createState() => _RouteAcceptState();
}

class _RouteAcceptState extends State<RouteAccept> {
  late final List<ListItem> _items = <ListItem>[];
  final _routeService = RouteService.getInstance();

  _RouteAcceptState();

  Future getRoutes() async {
    var _totalPages = 1;
    var _currentPage = 0;

    while (_currentPage < _totalPages) {
      var _response = await _routeService.getNewRoutesRequest(_currentPage++);
      print("Current page: ${_currentPage} Total pages: ${_totalPages}");
      if (_response.statusCode == 200) {
        PagedResult _pagedResult =
            PagedResult.fromJson(json.decode(_response.body));
        if (_pagedResult.isNotEmpty) {
          for (var route in _pagedResult.items) {
            _items.add(RouteModelItem(route));
          }
        }
        _totalPages = _pagedResult.totalPages;
      }
    }
  }

  Future RejectRoute(int index, RouteModel route) async {
    var _response = await _routeService.changeRouteStatusRequest(route.id, RouteStatusModel.Rejected);
    print(_response!.body);
    print("Code: ${_response.statusCode}");
    if (_response.statusCode == 204) {
      Helper.toastSuccessShort("Trasa zostałą odrzucona");
      setState(() {
        _items.removeAt(index);
      });
    } else if (_response.statusCode == 400) {
      var _json = json.decode(_response.body);
      Helper.toastFail("Niepowodzenie: ${_json['code']}");
    } else {
      var _json = json.decode(_response.body);
      Helper.toastFail("Wystąpił nieznany błąd: ${_json['code']}");
    }
    Navigator.pop(context, 'Odrzuć');
  }

  void onItemTap(RouteModel route){
    print("Tapped at route ${route.name}");
    Navigator.of(context).pushNamed('/route/show/new/details',
        arguments: route);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getRoutes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SpinKitSpinningCircle(
              color: Colors.white,
              size: 50.0,
            );
          }
          return ListOfRoutes();
        });
  }

  Widget ListOfRoutes() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Zarządzanie nowymi trasami"),
        ),
        body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return ListTile(
              title: item.buildTitle(context),
              subtitle: item.buildSubtitle(context),
              tileColor: item.buildTileColor(),
              onTap: () => {
                onItemTap(_items[index].getModel())
              },
              onLongPress: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        title: const Text('Odrzuć trasę'),
                        content: Text(
                            'Czy na pewno chcesz odrzucić trasę: "${_items[index].getModel().name}"?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'anuluj'),
                            child: const Text('anuluj'),
                          ),
                          TextButton(
                            onPressed: () =>
                                {RejectRoute(index, _items[index].getModel())},
                            child: const Text('Odrzuć'),
                          ),
                        ],
                      )),
            );
          },
        ),
      ),
    );
  }
}

abstract class ListItem {
  RouteModel getModel();

  Widget buildTitle(BuildContext context);

  Widget buildSubtitle(BuildContext context);

  Color buildTileColor();
}

class RouteModelItem implements ListItem {
  final RouteModel model;

  RouteModelItem(this.model);

  @override
  RouteModel getModel() {
    return model;
  }

  @override
  Widget buildTitle(BuildContext context) => Text(model.name);

  @override
  Widget buildSubtitle(BuildContext context) =>
      Text("Długość: ${model.length} metrów");

  @override
  Color buildTileColor() {
    int _color = 0xFFFFFFFF;
    switch (model.difficulty.toLowerCase()) {
      case 'green':
        _color = 0x6400FF00;
        break;
      case 'blue':
        _color = 0x640000FF;
        break;
      case 'red':
        _color = 0x64FF0000;
        break;
      case 'black':
        _color = 0x64000000;
        break;
    }
    return Color(_color);
  }
}
