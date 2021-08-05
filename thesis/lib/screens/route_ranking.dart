import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/AchievementModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/models/UserScoreModel.dart';
import 'package:thesis/services/achievement_service.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/run_service.dart';
import 'package:thesis/services/score_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class RouteRankingPage extends StatefulWidget {
  final RouteModel _model;

  const RouteRankingPage(this._model, {Key? key}) : super(key: key);

  @override
  _RouteRankingPageState createState() => _RouteRankingPageState(_model);
}

class _RouteRankingPageState extends State<RouteRankingPage> {
  final RouteModel _model;

  _RouteRankingPageState(this._model);

  RunService _runService = RunService.getInstance();
  var _totalPages = 1;
  var _currentPage = 1;

  final DateFormat _formatter = DateFormat('yyyy MMMM', 'pl_PL');
  DateTime _selectedDate = DateTime.now().toUtc();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    await _getRouteRanking();

    setState(() {
      _isLoading = false;
    });
  }

  Future _getRouteRanking() async {
    var _response = await _runService.getRunRankingRequest(
        _model.id, _formatter.format(_selectedDate), _currentPage);

    print("Current page: $_currentPage Total pages: $_totalPages");
    if (_response.statusCode == 200) {
      // PagedRouteModel _pagedResult =
      //   PagedRouteModel.fromJson(json.decode(_response.body));
      //if (_pagedResult.isNotEmpty) {
      //  for (var route in _pagedResult.items) {
      //    addRoute(route);
      // }
    }
    //_totalPages = _pagedResult.totalPages;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Ranking: ${_model.name}")),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView());
  }
}
