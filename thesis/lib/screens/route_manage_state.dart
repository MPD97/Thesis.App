import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/PagedRouteModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/models/RouteStatusModel.dart';
import 'package:thesis/services/route_service.dart';

class RouteAcceptPage extends StatefulWidget {
  RouteAcceptPage();

  @override
  _RouteAcceptPageState createState() => _RouteAcceptPageState();
}

class _RouteAcceptPageState extends State<RouteAcceptPage> {
  _RouteAcceptPageState();

  final List<RouteModel> _routes = [];
  final _routeService = RouteService.getInstance();

  int _currentPage = 0;
  int _totalPages = 1;

  final RefreshController refreshController = RefreshController(initialRefresh: true);

  Future<void> _onRefresh() async {
    _currentPage = 0;
    _routes.clear();
    refreshController.resetNoData();

    await _fetchData();

    refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await _fetchData();
  }

  Future _fetchData() async {
    final response =
    await _routeService.getNewRoutesRequest(++_currentPage);
    if (response.statusCode == 200) {
      var pagedModel = PagedRouteModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      setState(() {
        _routes.addAll(pagedModel.items);

        _currentPage = pagedModel.currentPage;
        _totalPages = pagedModel.totalPages;

        refreshController.loadComplete();
      });

      if (_currentPage >= _totalPages) {
        refreshController.loadNoData();
        return;
      } else {
        refreshController.loadComplete();
      }
    } else {
      refreshController.loadFailed();
    }
  }

  Future _rejectRoute(int index, RouteModel route) async {
    var _response = await _routeService.changeRouteStatusRequest(
        route.id, RouteStatusModel.Rejected);
    print(_response!.body);
    print("Code: ${_response.statusCode}");
    if (_response.statusCode == 204) {
      Helper.toastSuccessShort("Trasa zosta???? odrzucona");
      setState(() {
        _routes.removeAt(index);
      });
    } else if (_response.statusCode == 400) {
      var _json = json.decode(_response.body);
      Helper.toastFail("Niepowodzenie: ${_json['code']}");
    } else {
      var _json = json.decode(_response.body);
      Helper.toastFail("Wyst??pi?? nieznany b????d: ${_json['code']}");
    }
    Navigator.pop(context, 'Odrzu??');
  }

  void _onRouteTap(RouteModel route) {
    print("Tapped at route ${route.name}");
    Navigator.of(context)
        .pushNamed('/route/show/new/details', arguments: route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Zarz??dzanie nowymi trasami",
        style: TextStyle(),),
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus? mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = Text("poci??gnij aby od??wierzy??");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = Text("Wczytywanie nie powiod??o si??");
            } else if (mode == LoadStatus.canLoading) {
              body = Text("pu???? aby wczyta?? wi??cej");
            } else {
              body = Text("Brak dalszych wynik??w");
            }
            return Container(
              height: 55.h,
              child: Center(child: body),
            );
          },
        ),
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.separated(
          itemBuilder: (context, index) {
            final route = _routes[index];
            return ListTile(
              onTap: () => {_onRouteTap(route)},
              onLongPress: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Odrzu?? tras??'),
                    content: Text(
                        'Czy na pewno chcesz odrzuci?? tras??: "${route.name}"?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(context, 'anuluj'),
                        child: const Text('anuluj'),
                      ),
                      TextButton(
                        onPressed: () => {
                          _rejectRoute(
                              index, route)
                        },
                        child: const Text('Odrzu??'),
                      ),
                    ],
                  )),
              title: Text(route.name),
              subtitle: Text('d??ugo????: ${route.length} metr??w'),
              trailing: Text(route.difficulty),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: _routes.length,
        ),
      ),
    );
  }
}

