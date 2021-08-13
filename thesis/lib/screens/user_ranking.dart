import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thesis/AppColors.dart';
import 'package:thesis/Icons/CupIcon.dart';
import 'package:thesis/models/PagedUserRankingModel.dart';
import 'package:thesis/models/UserDetailsModel.dart';
import 'package:thesis/services/auth_service.dart';
import 'package:thesis/services/score_service.dart';
import 'package:thesis/services/user_service.dart';

class UserRankingPage extends StatefulWidget {

  const UserRankingPage({Key? key}) : super(key: key);

  @override
  _UserRankingPageState createState() => _UserRankingPageState();
}

class _UserRankingPageState extends State<UserRankingPage> {
  _UserRankingPageState();

  final RefreshController refreshController =
  RefreshController(initialRefresh: true);

  ScoreService _scoreService = ScoreService.getInstance();
  UserService _userService = UserService.getInstance();

  List<ScoreOverallModel> _scoreModel = [];
  var _totalPages = 1;
  var _currentPage = 1;

  final _userDetails = <UserDetails>[];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _onRefresh() async {
    _currentPage = 0;
    _scoreModel.clear();
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
    final response = await _scoreService.getOverallRankingRequest(++_currentPage);
    if (response.statusCode == 200) {
      var pagedModel = PagedUserRankingModel.fromJson(
          json.decode(utf8.decode(response.bodyBytes)));
      setState(() {
        _scoreModel.addAll(pagedModel.items);

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
    for (var rank in _scoreModel) {
      allIds.add(rank.id);
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

  String _tryGetPseudonym(String userId) {
    var _query = _userDetails.where((ud) => ud.id == userId);
    if (_query.isEmpty) {
      return '<pseudonim>';
    }
    return _query.first.pseudonym;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ranking graczy"),
      ),
      body: SmartRefresher(
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
            final score = _scoreModel[index];
            return ListTile(
              onTap: () => {
                Navigator.of(context).pushNamed('/user', arguments: score.id)
              },
              onLongPress: () {
                if (AuthService.isUserAdmin()) {
                  Navigator.of(context)
                      .pushNamed('/user/lock', arguments: score.id);
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
                _tryGetPseudonym(score.id),
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
              trailing: Text('${score.score} punktów',
                style: TextStyle(color: Colors.blue, fontSize: 14.sp),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: _scoreModel.length,
        ),
      ),
    );
  }
}
