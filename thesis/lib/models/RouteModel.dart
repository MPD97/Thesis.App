import 'PointModel.dart';

class RouteModel {
  late String id;
  late String userId;
  late String acceptedBy;
  late String name;
  late String description;
  late String difficulty;
  late int length;
  late String status;
  late String activityKind;
  late List<PointModel> points;

  RouteModel(this.id,
        this.userId,
        this.acceptedBy,
        this.name,
        this.description,
        this.difficulty,
        this.length,
        this.status,
        this.activityKind,
        this.points);

  RouteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    acceptedBy = json['acceptedBy'];
    name = json['name'];
    description = json['description'];
    difficulty = json['difficulty'];
    length = json['length'];
    status = json['status'];
    activityKind = json['activityKind'];
    if (json['points'] != null) {
      points = <PointModel>[];
      json['points'].forEach((v) {
        points.add(new PointModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['acceptedBy'] = this.acceptedBy;
    data['name'] = this.name;
    data['description'] = this.description;
    data['difficulty'] = this.difficulty;
    data['length'] = this.length;
    data['status'] = this.status;
    data['activityKind'] = this.activityKind;
    if (this.points != null) {
      data['points'] = this.points.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
