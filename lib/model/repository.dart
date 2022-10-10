class Repository {
  String id;
  String name;
  String? description;
  String url;
  String updatedAt;

  Repository({
    required this.id,
    required this.name,
    this.description,
    required this.url,
    required this.updatedAt,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      url: json['url'],
      updatedAt: json['updatedAt'],
    );
  }
}
