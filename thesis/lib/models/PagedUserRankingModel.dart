class PagedUserRankingModel {
  late List<ScoreOverallModel> items;
  late bool isEmpty;
  late bool isNotEmpty;
  late int currentPage;
  late int resultsPerPage;
  late int totalPages;
  late int totalResults;

  PagedUserRankingModel(
      this.items,
        this.isEmpty,
        this.isNotEmpty,
        this.currentPage,
        this.resultsPerPage,
        this.totalPages,
        this.totalResults);

  PagedUserRankingModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <ScoreOverallModel>[];
      json['items'].forEach((v) {
        items.add(new ScoreOverallModel.fromJson(v));
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

class ScoreOverallModel {
  late String id;
  late int score;

  ScoreOverallModel(this.id, this.score);

  ScoreOverallModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['score'] = this.score;
    return data;
  }
}