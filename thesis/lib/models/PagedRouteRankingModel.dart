class PagedRouteRankingModel {
  late List<RankingModel> items;
  late bool isEmpty;
  late bool isNotEmpty;
  late int currentPage;
  late int resultsPerPage;
  late int totalPages;
  late int totalResults;

  PagedRouteRankingModel(
      this.items,
        this.isEmpty,
        this.isNotEmpty,
        this.currentPage,
        this.resultsPerPage,
        this.totalPages,
        this.totalResults);

  PagedRouteRankingModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <RankingModel>[];
      json['items'].forEach((v) {
        items.add(new RankingModel.fromJson(v));
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
    data['items'] = this.items.map((v) => v.toJson()).toList();
    data['isEmpty'] = this.isEmpty;
    data['isNotEmpty'] = this.isNotEmpty;
    data['currentPage'] = this.currentPage;
    data['resultsPerPage'] = this.resultsPerPage;
    data['totalPages'] = this.totalPages;
    data['totalResults'] = this.totalResults;
    return data;
  }
}

class RankingModel {
  late String userId;
  late String runDate;
  late String time;

  RankingModel(this.userId, this.runDate, this.time);

  RankingModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    runDate = json['runDate'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['runDate'] = this.runDate;
    data['time'] = this.time;
    return data;
  }
}