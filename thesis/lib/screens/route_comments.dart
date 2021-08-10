import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thesis/models/PagedCommentModel.dart';
import 'package:thesis/models/RouteModel.dart';
import 'package:thesis/models/UserDetailsModel.dart';
import 'package:thesis/services/comments_service.dart';
import 'package:thesis/services/user_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RouteCommentsPage extends StatefulWidget {
  late final RouteModel _model;

  RouteCommentsPage(this._model, {Key? key}) : super(key: key) {}

  @override
  _RouteCommentsPageState createState() => _RouteCommentsPageState(_model);
}

class _RouteCommentsPageState extends State<RouteCommentsPage> {
  final RouteModel _model;

  _RouteCommentsPageState(this._model) {}

  final CommentsService _commentService = CommentsService.getInstance();
  final UserService _userService = UserService.getInstance();

  int _currentPage = 0;
  int _totalPages = 1;

  final List<UserDetails> _userDetails = [];
  final List<CommentModel> _comments = [];

  final RefreshController refreshController =
      RefreshController(initialRefresh: true);

  Future<void> _onRefresh() async {
    _currentPage = 0;
    _comments.clear();
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
    final response =
        await _commentService.getCommentsRequest(_model.id, ++_currentPage);
    if (response.statusCode == 200) {
      var pagedModel = PagedCommentModel.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      setState(() {
        _comments.addAll(pagedModel.items);

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
    var _allUsersIds = [];
    for (var rank in _comments) {
      _allUsersIds.add(rank.userId);
    }
    _allUsersIds = _allUsersIds.toSet().toList();

    for (var uniqueId in _allUsersIds) {
      if (_userDetails.where((d) => d.id == uniqueId).isNotEmpty) {
        continue;
      }
      var _response = await _userService.getUserDetailsRequest(uniqueId);
      if (_response.statusCode == 200) {
        var details = UserDetails.fromJson(json.decode(utf8.decode(_response.bodyBytes)));
        _userDetails.add(details);
      } else {
        print("Code: ${_response.statusCode}");
      }
    }
    setState(() {

    });
  }

  String _getTimeDifference(DateTime now, DateTime to) {
    final Duration difference = now.difference(to);
    if (difference.inDays > 0) {
      return '${difference.inDays} dni temu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} godzin temu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minut temu';
    } else {
      return 'przed chwilą';
    }
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
        title: Text("Komentarze: ${_model.name}"),
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
            final comment = _comments[index];
            return ListTile(
              onTap: () =>{Navigator.of(context).pushNamed('/user', arguments: comment.userId) },
              leading: const Icon(
                Icons.perm_identity,
                size: 50,
                color: Colors.blue,
              ),
              title: Text(_tryGetPseudonym(comment.userId)),
              subtitle: Text(comment.text),
              trailing: Text(
                _getTimeDifference(
                    DateTime.now().toUtc(), DateTime.parse(comment.createdAt)),
                style: TextStyle(color: Colors.green),
              ),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: _comments.length,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .pushNamed("/route/comments/add", arguments: _model);
        },
        label: const Text('Dodaj komentarz'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
