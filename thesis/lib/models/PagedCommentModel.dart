class PagedCommentModel {
  late List<CommentModel> items;
  late bool isEmpty;
  late bool isNotEmpty;
  late int currentPage;
  late int resultsPerPage;
  late int totalPages;
  late int totalResults;

  PagedCommentModel(
      this.items,
        this.isEmpty,
        this.isNotEmpty,
        this.currentPage,
        this.resultsPerPage,
        this.totalPages,
        this.totalResults);

  PagedCommentModel.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <CommentModel>[];
      json['items'].forEach((v) {
        items.add(new CommentModel.fromJson(v));
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

class CommentModel {
  late String id;
  late String userId;
  late String routeId;
  late String createdAt;
  late String text;

  CommentModel(this.id, this.userId, this.routeId, this.createdAt, this.text);

  CommentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['userId'];
    routeId = json['routeId'];
    createdAt = json['createdAt'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['userId'] = this.userId;
    data['routeId'] = this.routeId;
    data['createdAt'] = this.createdAt;
    data['text'] = this.text;
    return data;
  }
}