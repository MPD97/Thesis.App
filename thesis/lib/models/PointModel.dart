class PointModel {
  late String id;
  late int order;
  late double latitude;
  late double longitude;
  late int radius;

  PointModel(this.id, this.order, this.latitude, this.longitude, this.radius);

  PointModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    order = json['order'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    radius = json['radius'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['order'] = this.order;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['radius'] = this.radius;
    return data;
  }
}