import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/Icons/CupIcon.dart';
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

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  RunService _runService = RunService.getInstance();
  UserService _userService = UserService.getInstance();

  List<RankingModel> _rankingModel = [];
  var _totalPages = 1;
  var _currentPage = 1;

  final _userDetails = <UserDetails>[];

  DateTime _selectedDate = DateTime.now().toUtc();
  final DateFormat _formatterDate = DateFormat('yyyy MMMM');

  Future<void> _onRefresh() async {
    _currentPage = 0;
    _rankingModel.clear();
    refreshController.resetNoData();

    await _fetchData();
    await _buildDistinctUserIds();

    refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await _fetchData();
    await _buildDistinctUserIds();
  }

  Future _fetchData() async {
    final response = await _runService.getRunRankingRequest(
        _model.id, _formatterDate.format(_selectedDate), ++_currentPage);
    if (response.statusCode == 200) {
      var pagedModel = PagedRouteRankingModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)));
      setState(() {
        _rankingModel.addAll(pagedModel.items);

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
    setState(() {});
  }

  Future previousMonthClick() async {
    _selectedDate = DateTime(
        _selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
    _currentPage = 1;
    await _onRefresh();
  }

  Future nextMonthClick() async {
    _selectedDate = DateTime(
        _selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
    _currentPage = 1;
    await _onRefresh();
  }

  String _tryGetPseudonym(String userId) {
    var _query = _userDetails.where((ud) => ud.id == userId);
    if (_query.isEmpty) {
      return '<pseudonim>';
    }
    return _query.first.pseudonym;
  }

  String _getPLMonth(DateTime date) {
    switch (date.month) {
      case 1:
        return 'Styczeń';
      case 2:
        return 'Luty';
      case 3:
        return 'Marzec';
      case 4:
        return 'Kwiecień';
      case 5:
        return 'Maj';
      case 6:
        return 'Czerwiec';
      case 7:
        return 'Lipiec';
      case 8:
        return 'Sierpień';
      case 9:
        return 'Wrzesień';
      case 10:
        return 'Październik';
      case 11:
        return 'Listopad';
      case 12:
        return 'Grudzień';
      default:
        return '<miesiąc>';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ranking trasy: ${_model.name}"),
      ),
      body: Column(
        children: [
          Container(
            height: 75.h,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.h),
                    child: SizedBox(
                      width: 50.w,
                      child: TextButton(
                        onPressed: () => {previousMonthClick()},
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(AppColors.LIGHT),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(vertical: 14.h)),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ))),
                        child: Icon(
                          Icons.skip_previous,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 200.w,
                    child: TextButton(
                      onPressed: () => {},
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all(AppColors.PRIMARY),
                          padding: MaterialStateProperty.all(
                              EdgeInsets.symmetric(vertical: 14.h)),
                          textStyle: MaterialStateProperty.all(TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ))),
                      child: Text(
                        '${_selectedDate.year} ${_getPLMonth(_selectedDate)}',
                        style: TextStyle(
                            fontSize: 16.sp, color: AppColors.PRIMARY),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.h),
                    child: SizedBox(
                      width: 50.w,
                      child: TextButton(
                        onPressed: () => {nextMonthClick()},
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(AppColors.LIGHT),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.white),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(vertical: 14.h)),
                            textStyle: MaterialStateProperty.all(TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ))),
                        child: Icon(
                          Icons.skip_next,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: SmartRefresher(
                controller: refreshController,
                enablePullUp: true,
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus? mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("pociągnij aby odświerzyć");
                    } else if (mode == LoadStatus.loading) {
                      body = CupertinoActivityIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Wczytywanie nie powiodło się");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text("puść aby wczytać więcej");
                    } else {
                      body = Text("Brak dalszych wyników");
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
                    final ranking = _rankingModel[index];
                    return ListTile(
                      onTap: () =>{Navigator.of(context).pushNamed('/user', arguments: ranking.userId) },
                      onLongPress: () {
                        if (AuthService.isUserAdmin()) {
                          Navigator.of(context)
                              .pushNamed('/user/lock', arguments: ranking.userId);
                        }
                      },
                      leading: index < 3
                          ? Icon(
                              CupIcons.CUP,
                              size: 50,
                              color: index == 0
                                  ? AppColors.GOLD
                                  : index == 1
                                      ? AppColors.SILVER
                                      : index == 2
                                          ? AppColors.BRONZE
                                          : Colors.blue,
                            )
                          : Text(
                              "#${index + 1}",
                              style: index < 10
                                  ? TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold)
                                  : TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.normal),
                            ),
                      title: Text(
                        _tryGetPseudonym(ranking.userId),
                        style: TextStyle(
                            fontSize: index == 0
                                ? 24.sp
                                : index == 1
                                    ? 20.sp
                                    : index == 2
                                        ? 18.sp
                                        : index < 10
                                            ? 16.sp
                                            : 14.sp),
                      ),
                      trailing: Text(
                        _printDuration(parseDuration(ranking.time)),
                        style: TextStyle(color: Colors.blue, fontSize: 14.sp),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(),
                  itemCount: _rankingModel.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _printDuration(Duration duration) {
    if (duration.inHours >= 24) {
      return "ponad 24h";
    }
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
