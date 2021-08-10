class UserRankingPlaceModel {
  late String id;
  late int place;

  UserRankingPlaceModel(this.id, this.place);

  UserRankingPlaceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    place = json['place'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['place'] = this.place;
    return data;
  }
}