import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:thesis/models/PagedRouteRankingModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/models/UserDetailsModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/run_service.dart';
import 'package:thesis/services/user_service.dart';

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
  UserService _userService = UserService.getInstance();

  List<RankingModel> _rankingModel = [];
  var _totalPages = 1;
  var _currentPage = 1;

  final _userDetails = <UserDetails>[];

  DateTime _selectedDate = DateTime.now().toUtc();
  final DateFormat _formatterDate = DateFormat('yyyy MMMM');
  final DateFormat _formatterTime = DateFormat('mm:ss.fff');

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
    _rankingModel.clear();

    await _getRouteRanking();
    await _buildDistinctUserIds();

    setState(() {
      _isLoading = false;
    });
  }

  Future _buildDistinctUserIds() async {
    var allIds = [];
    for (var rank in _rankingModel) {
      allIds.add(rank.userId);
    }
    allIds.toSet().toList();

    for (var uniqueId in allIds) {
      if (_userDetails.where((d) => d.id == uniqueId).isNotEmpty) {
        continue;
      }
      var _response = await _userService.getUserDetailsRequest(uniqueId);
      if (_response.statusCode == 200) {
        var details = UserDetails.fromJson(json.decode(_response.body));
        _userDetails.add(details);
      } else {
        print("Code: ${_response.statusCode}");
      }
    }
  }

  Future _getRouteRanking() async {
    var _response = await _runService.getRunRankingRequest(
        _model.id, _formatterDate.format(_selectedDate), _currentPage);

    print("Current page: $_currentPage Total pages: $_totalPages");
    if (_response.statusCode == 200) {
      PagedRouteRankingModel _pagedResult =
          PagedRouteRankingModel.fromJson(json.decode(_response.body));
      if (_pagedResult.isNotEmpty) {
        _rankingModel.addAll(_pagedResult.items);
      }
      _totalPages = _pagedResult.totalPages;
    }
  }

  void previusMonthClick() {
    _selectedDate = DateTime(
        _selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
    _currentPage = 1;
    _fetchData();
  }

  void nextMonthClick() {
    _selectedDate = DateTime(
        _selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
    _currentPage = 1;
    _fetchData();
  }

  Future nextPage() async {
    _currentPage += 1;
    await _fetchData();
  }

  Future previousPage() async {
    _currentPage -= 1;
    await _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Ranking: ${_model.name}")),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Stack(
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                color: Colors.white,
                                height: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    GestureDetector(
                                        onTap: () => {previusMonthClick()},
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: EdgeInsets.all(15),
                                            child: Icon(
                                              Icons.navigate_before,
                                              size: 32,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        )),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Text(
                                            _formatterDate
                                                .format(_selectedDate),
                                            style: TextStyle(fontSize: 20),
                                          )),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    GestureDetector(
                                        onTap: () => {nextMonthClick()},
                                        child: Card(
                                          elevation: 6,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          child: Padding(
                                            padding: EdgeInsets.all(15),
                                            child: Icon(
                                              Icons.navigate_next,
                                              size: 32,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          for (var entry in _rankingModel)
                            Row(
                              children: [
                                GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed('/user',
                                          arguments: entry.userId);
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 2, vertical: 2),
                                      color: Colors.white,
                                      height: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Card(
                                            elevation: 6,
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    color: entry.userId ==
                                                            AuthService.meId
                                                        ? Color(0xFFF6E9A5)
                                                        : Color(0xFFFFFFFF),
                                                    width: 4.0),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width -
                                                            52,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          (_rankingModel.indexOf(
                                                                      entry) +
                                                                  1 +
                                                                  10 *
                                                                      (_currentPage -
                                                                          1))
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Text(
                                                          _printDuration(
                                                              parseDuration(
                                                                  entry.time)),
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        SizedBox(
                                                            width: (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width) -
                                                                180,
                                                            child: Text(
                                                              _userDetails
                                                                  .where((d) =>
                                                                      d.id ==
                                                                      entry
                                                                          .userId)
                                                                  .first
                                                                  .pseudonym,
                                                              style: TextStyle(
                                                                  fontSize: 20),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            )),
                                                      ],
                                                    ))),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          _totalPages > 1
                              ? Row(
                                  children: [
                                    _currentPage > 1
                                        ? GestureDetector(
                                            onTap: () {
                                              previousPage();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                              color: Colors.white,
                                              height: 100,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Card(
                                                    elevation: 6,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child: SizedBox(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                52,
                                                            child: Text(
                                                                "Poprzednia strona"))),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        : SizedBox.shrink(),
                                    _currentPage < _totalPages
                                        ? GestureDetector(
                                            onTap: () {
                                              nextPage();
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 2,
                                                      vertical: 2),
                                              color: Colors.white,
                                              height: 100,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Card(
                                                    elevation: 6,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                    child: Padding(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child: SizedBox(
                                                            width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2 -
                                                                52,
                                                            child: Text(
                                                                "Następna strona"))),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        : SizedBox.shrink()
                                  ],
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }
}
