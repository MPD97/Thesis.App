class AchievementModel {
  late String id;
  late List<Achievements> achievements;

  AchievementModel(this.id, this.achievements);

  AchievementModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['achievements'] != null) {
      achievements = <Achievements>[];
      json['achievements'].forEach((v) {
        achievements.add(new Achievements.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['achievements'] = this.achievements.map((v) => v.toJson()).toList();
    return data;
  }
}

class Achievements {
  late String id;
  late String type;
  late String message;
  late String createdAt;

  Achievements(this.id, this.type, this.message, this.createdAt);

  Achievements.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    message = json['message'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['message'] = this.message;
    data['createdAt'] = this.createdAt;
    return data;
  }
}