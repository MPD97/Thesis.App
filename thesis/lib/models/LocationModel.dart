class LocationModel {
  late int Order;
  late double Latitude;
  late double Longitude;
  late int Radius;

  LocationModel(double latitude, double longitude, int radius, int order) {
    this.Order = order;
    this.Latitude = latitude;
    this.Longitude = longitude;
    this.Radius = radius;
  }

  Map<String, dynamic> toJson() {
    return {
      "order": this.Order,
      "latitude": this.Latitude,
      "longitude": this.Longitude,
      "radius": this.Radius
    };
  }
}
