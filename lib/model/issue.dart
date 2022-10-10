class Issue {
  String id;
  String title;
  String? body;
  String url;
  String updatedAt;

  Issue({
    required this.id,
    required this.title,
    this.body,
    required this.url,
    required this.updatedAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      url: json['url'],
      updatedAt: json['updatedAt'],
    );
  }
}
