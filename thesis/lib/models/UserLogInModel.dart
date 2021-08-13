class UserLogInModel {
  late String accessToken;
  late String refreshToken;
  late String role;
  late int expires;

  UserLogInModel(
      this.accessToken, this.refreshToken, this.role, this.expires);

  UserLogInModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    role = json['role'];
    expires = json['expires'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['role'] = this.role;
    data['expires'] = this.expires;
    return data;
  }
}