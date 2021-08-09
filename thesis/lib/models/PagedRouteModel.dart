import 'RouteModel.dart';

class PagedRouteModel {
  late List<RouteModel> items;
  late bool isEmpty;
  late bool isNotEmpty;
  late int currentPage;
  late int resultsPerPage;
  late int totalPages;
  late int totalResults;

  PagedRouteModel(
      this.items,
        this.isEmpty,
        this.isNotEmpty,
        this.currentPage,
        this.resultsPerPage,
        this.totalPages,
        this.totalResults);

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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items.map((v) => v.toJson()).toList();
    }
    data['isEmpty'] = this.isEmpty;
    data['isNotEmpty'] = this.isNotEmpty;
    data['currentPage'] = this.currentPage;
    data['resultsPerPage'] = this.resultsPerPage;
    data['totalPages'] = this.totalPages;
    data['totalResults'] = this.totalResults;
    return data;
  }
}