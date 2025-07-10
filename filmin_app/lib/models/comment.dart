class Comment {
  final String content;
  final String username;
  final DateTime createdAt;

  Comment(
      {required this.content, required this.username, required this.createdAt});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      content: json['content'],
      username: json['user']['name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
