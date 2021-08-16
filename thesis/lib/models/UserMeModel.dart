class UserMeModel {
  late String pseudonym;
  late String id;
  late String state;
  late String createdAt;

  UserMeModel(
      this.pseudonym,
        this.id,
        this.state,
        this.createdAt);

  UserMeModel.fromJson(Map<String, dynamic> json) {
    pseudonym = json['pseudonym'];
    id = json['id'];
    state = json['state'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pseudonym'] = this.pseudonym;
    data['id'] = this.id;
    data['state'] = this.state;
    data['createdAt'] = this.createdAt;
    return data;
  }
}