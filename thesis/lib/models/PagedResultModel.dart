import 'RouteModel.dart';

class PagedRouteModel {
  late List<RouteModel> items;
  late bool isEmpty;
  late bool isNotEmpty;
  late int currentPage;
  late int resultsPerPage;
  late int totalPages;
  late int totalResults;

  PagedRouteModel(this.items, this.isEmpty, this.isNotEmpty, this.currentPage,
      this.resultsPerPage, this.totalPages, this.totalResults);

  PagedRouteModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <RouteModel>[];
      json['items'].forEach((v) {
        items.add(new RouteModel.fromJson(v));
      });
    }
    isEmpty = json['isEmpty'];
    isNotEmpty = json['isNotEmpty'];
    currentPage = json['currentPage'];
    resultsPerPage = json['resultsPerPage'];
    totalPages = json['totalPages'];
    totalResults = json['totalResults'];
  }
}
