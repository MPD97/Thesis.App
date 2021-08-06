class UserScoreModel {
  late String id;
  late int score;
  late List<ScoreEventModel> scoreEvents;

  UserScoreModel(
      {required this.id, required this.score, required this.scoreEvents});

  UserScoreModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    score = json['score'];
    if (json['scoreEvents'] != null) {
      scoreEvents = <ScoreEventModel>[];
      json['scoreEvents'].forEach((v) {
        scoreEvents.add(new ScoreEventModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['score'] = this.score;
    data['scoreEvents'] = this.scoreEvents.map((v) => v.toJson()).toList();
    return data;
  }
}

class ScoreEventModel {
  late String id;
  late String message;
  late String createsAt;
  late int amount;
  late String type;
  late String routeId;
  late Null date;

  ScoreEventModel(
      {required this.id,
      required this.message,
      required this.createsAt,
      required this.amount,
      required this.type,
      required this.routeId,
      this.date});

  ScoreEventModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    message = json['message'];
    createsAt = json['createsAt'];
    amount = json['amount'];
    type = json['type'];
    routeId = json['routeId'];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['message'] = this.message;
    data['createsAt'] = this.createsAt;
    data['amount'] = this.amount;
    data['type'] = this.type;
    data['routeId'] = this.routeId;
    data['date'] = this.date;
    return data;
  }
}
