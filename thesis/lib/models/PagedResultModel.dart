import 'RouteModel.dart';

class PagedResult {
  late List<RouteModel> items;
  late bool isEmpty;
  late bool isNotEmpty;
  late int currentPage;
  late int resultsPerPage;
  late int totalPages;
  late int totalResults;

  PagedResult(this.items,
      this.isEmpty,
      this.isNotEmpty,
      this.currentPage,
      this.resultsPerPage,
      this.totalPages,
      this.totalResults);

  PagedResult.fromJson(Map<String, dynamic> json) {
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
