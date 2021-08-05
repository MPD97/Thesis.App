import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thesis/helpers/helper.dart';
import 'package:thesis/models/AchievementModel.dart';
import 'package:thesis/models/UserDetailsModel.dart';
import 'package:thesis/models/UserScoreModel.dart';
import 'package:thesis/services/achievement_service.dart';
import 'package:thesis/services/score_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:thesis/services/user_service.dart';

class UserDetailsPage extends StatefulWidget {
  late String userId;

  UserDetailsPage(this.userId);

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState(userId);
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  late String _userId;

  _UserDetailsPageState(this._userId);

  final _scoreService = ScoreService.getInstance();
  final _achievementService = AchievementService.getInstance();
  final _userService = UserService.getInstance();

  UserScoreModel? _userScoreModel;
  AchievementModel? _achievementModel;
  UserDetails? _userDetails;

  Color _bestAchievementColor = Color(0xFFFFFF);

  double _nextAchievementProgress = 0;
  int _routeAddedAmount = 0;
  int _routeCompletedAmount = 0;
  int _routeCommentedAmount = 0;
  int _routeFirstAmount = 0;
  int _routeSecondAmount = 0;
  int _routeThirdAmount = 0;
  int _routeTopTenAmount = 0;

  bool _isLoading = true;

  final DateFormat _formatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future _fetchData() async {
    await _getUserAchievements();
    await _getUserScore();
    await _getUserDetails();
    getBestAchievementColor();

    setState(() {
      _isLoading = false;
    });
  }

  Future _getUserDetails() async {
    var _response = await _userService.getUserDetailsRequest(_userId);
    if (_response.statusCode == 200) {
      _userDetails = UserDetails.fromJson(json.decode(_response.body));
    } else {
      print("Code: ${_response.statusCode}");
    }
  }

  Future _getUserScore() async {
    final _response =
    await _scoreService.getUserScoreRequest(_userId);
    if (_response!.statusCode == 200) {
      setState(() {
        _userScoreModel = UserScoreModel.fromJson(json.decode(_response.body));
        getAchievementProgress();
        matchScoreEvents();
      });
    } else if (_response.statusCode == 400) {
      Helper.toastFailShort("Nie znaleziono użytkownika");
    } else {
      Helper.toastFail("Nieznany błąd: ${json.decode(_response.body)['code']}");
    }
  }

  Future _getUserAchievements() async {
    final _response =
    await _achievementService.getAchievementsRequest(_userId);
    if (_response!.statusCode == 200) {
      setState(() {
        _achievementModel =
            AchievementModel.fromJson(json.decode(_response.body));
      });
    } else if (_response.statusCode == 404) {} else {
      Helper.toastFail("Nieznany błąd: ${json.decode(_response.body)['code']}");
    }
  }

  void getBestAchievementColor() {
    if (_achievementModel!.achievements.any((se) => se.type == 'master')) {
      _bestAchievementColor = const Color(0XFF6E86FF);
    } else if (_achievementModel!.achievements.any((se) => se.type == 'gold')) {
      _bestAchievementColor = const Color(0XFFFFD700);
    } else if (_achievementModel!.achievements
        .any((se) => se.type == 'silver')) {
      _bestAchievementColor = const Color(0XFFC0C0C0);
    } else if (_achievementModel!.achievements
        .any((se) => se.type == 'bronze')) {
      _bestAchievementColor = const Color(0xFFCD7F32);
    }
  }

  void getAchievementProgress() {
    setState(() {
      if (_userScoreModel == null) {
        print("UserScore == null");
        return;
      }
      if (_userScoreModel!.score < 30) {
        _nextAchievementProgress = _userScoreModel!.score / 30;
      } else if (_userScoreModel!.score < 100) {
        _nextAchievementProgress = _userScoreModel!.score / 100;
      } else if (_userScoreModel!.score < 300) {
        _nextAchievementProgress = _userScoreModel!.score / 300;
      } else if (_userScoreModel!.score < 1000) {
        _nextAchievementProgress = _userScoreModel!.score / 1000;
      } else {
        _nextAchievementProgress = 0.0;
      }
      _nextAchievementProgress *= 100;
    });
  }

  void matchScoreEvents() {
    setState(() {
      for (var se in _userScoreModel!.scoreEvents) {
        if (se.type == "routeAdded") {
          _routeAddedAmount += 1;
        } else if (se.type == "routeCompleted") {
          _routeCompletedAmount += 1;
        } else if (se.type == "routeTopTen") {
          _routeTopTenAmount += 1;
        } else if (se.type == "routeThird") {
          _routeThirdAmount += 1;
        } else if (se.type == "routeSecond") {
          _routeSecondAmount += 1;
        } else if (se.type == "routeFirst") {
          _routeFirstAmount += 1;
        } else if (se.type == "routeCommented" ||
            se.type == "routeCommentedWithPhoto") {
          _routeCommentedAmount += 1;
        } else {
          print("Event not matched: ${se.type}");
        }
      }
    });
  }

  List<TableRow> buildRows() {
    return [
      TableRow(
        children: [
          ProfileInfoBigCard(
            firstText: _routeAddedAmount.toString(),
            secondText: "Dodanych tras",
            icon: const Icon(
              Icons.add,
              size: 32,
              color: Colors.blue,
            ),
          ),
          ProfileInfoBigCard(
            firstText: _routeCompletedAmount.toString(),
            secondText: "Ukończonych tras",
            icon: const Icon(
              Icons.check,
              size: 32,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          ProfileInfoBigCard(
            firstText: _routeFirstAmount.toString(),
            secondText: "Top 1 tras",
            icon: const Icon(
              Icons.leaderboard_outlined,
              size: 32,
              color: Colors.blue,
            ),
          ),
          ProfileInfoBigCard(
            firstText: _routeSecondAmount.toString(),
            secondText: "Top 2 tras",
            icon: const Icon(
              Icons.leaderboard_outlined,
              size: 32,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      TableRow(
        children: [
          ProfileInfoBigCard(
            firstText: _routeThirdAmount.toString(),
            secondText: "Top 3 tras",
            icon: const Icon(
              Icons.leaderboard_outlined,
              size: 32,
              color: Colors.blue,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: ProfileInfoBigCard(
              firstText: _routeTopTenAmount.toString(),
              secondText: "Top 10 tras",
              icon: const Icon(
                Icons.leaderboard_outlined,
                size: 32,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: _isLoading ? Text("Wczytywanie") : Text("Użytkownik: ${_userDetails!.pseudonym}")),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Stack(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Stack(
                          children: <Widget>[
                            Row(children: [
                              Container(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width,
                                padding: const EdgeInsets.only(top: 0),
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Container(
                                      width: 100,
                                      alignment: Alignment.center,
                                      height: 100,
                                      margin: const EdgeInsets.only(
                                          top: 15, bottom: 15),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                'https://www.marinasmediterraneo.com/marinaseste/wp-content/uploads/sites/4/2018/09/generic-user-purple-4.png'),
                                            fit: BoxFit.fill),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _bestAchievementColor
                                                .withOpacity(1.0),
                                            spreadRadius: 5,
                                            blurRadius: 14,
                                            offset: Offset(0,
                                                0), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                    ),
                                    MyInfo(_userDetails!.pseudonym),
                                    Row(children: [
                                      Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          color: Colors.white,
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 60,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  mainAxisSize: MainAxisSize
                                                      .max,
                                                  children: <Widget>[
                                                    ProfileInfoCard(
                                                        firstText: _userScoreModel!
                                                            .score.toString(),
                                                        secondText: "punktów energii"),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    ProfileInfoCard(
                                                        firstText:
                                                        "${_nextAchievementProgress
                                                            .toInt()}%",
                                                        secondText: "do osiągnięcia"),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    ProfileInfoCard(
                                                        firstText: "-",
                                                        secondText: "Top graczy"),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ))
                                    ]),
                                  ],
                                ),
                              )
                            ]),
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          padding: const EdgeInsets.only(top: 10),
                          color: Colors.white,
                          child: Table(
                              children: _achievementModel!.achievements
                                  .map((ac) =>
                                  TableRow(
                                    children: [
                                      ProfileAchievementBigCard(
                                        firstText: case2(ac.type, {
                                          "bronze":
                                          "Brązowy medal energii",
                                          "silver":
                                          "Srebrny medal energii",
                                          "gold":
                                          "Złoty medal enrgii",
                                          "master": "Mistrz energii",
                                        }),
                                        secondText: _formatter.format(
                                            DateTime.parse(
                                                ac.createdAt)
                                                .toLocal()),
                                        achievementType: ac.type,
                                      ),
                                    ],
                                  ))
                                  .toList()),
                        )
                      ],
                    ),
                    Row(children: [
                      Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        padding: const EdgeInsets.only(top: 10),
                        color: Colors.white,
                        child: Table(children: buildRows()),
                      )
                    ]),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class MyInfo extends StatelessWidget {
  late String pseudonym;
  MyInfo(this.pseudonym);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: MediaQuery
                .of(context)
                .size
                .width,
            padding: const EdgeInsets.only(top: 0),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        pseudonym,
                        style: TextStyle(fontSize: 24)),
                  ],
                ),
              ],
            ))
      ],
    );
  }
}

class ProfileInfoBigCard extends StatelessWidget {
  final String firstText, secondText;
  final Widget icon;

  ProfileInfoBigCard({required this.firstText,
    required this.secondText,
    required this.icon}) {}

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 16,
          bottom: 24,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: Alignment.topRight,
              child: icon,
            ),
            Text(
              firstText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(secondText),
          ],
        ),
      ),
    );
  }
}

TValue case2<TOptionType, TValue>(TOptionType selectedOption,
    Map<TOptionType, TValue> branches, [
      TValue? defaultValue = null,
    ]) {
  if (!branches.containsKey(selectedOption)) {
    return defaultValue!;
  }

  return branches[selectedOption]!;
}

class ProfileAchievementBigCard extends StatelessWidget {
  final String firstText, secondText, achievementType;

  ProfileAchievementBigCard({required this.firstText,
    required this.secondText,
    required this.achievementType}) {}

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
            color: case2(achievementType, {
              "bronze": Color(0xFFCD7F32),
              "silver": Color(0XFFC0C0C0),
              "gold": Color(0XFFFFD700),
              "master": Color(0XFF6E86FF),
            }),
            width: 4.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16.0,
          top: 16,
          bottom: 24,
          right: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              firstText,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              secondText,
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoCard extends StatelessWidget {
  final firstText, secondText, hasImage, imagePath;

  const ProfileInfoCard(
      {this.firstText, this.secondText, this.hasImage = false, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: hasImage
            ? Center(
          child: Image.asset(
            imagePath,
            color: Colors.white,
            width: 25,
            height: 25,
          ),
        )
            : TwoLineItem(
          firstText: firstText,
          secondText: secondText,
        ),
      ),
    );
  }
}

class TwoLineItem extends StatelessWidget {
  final String firstText, secondText;

  TwoLineItem({required this.firstText, required this.secondText}) {}

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          firstText,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          secondText,
        ),
      ],
    );
  }
}
