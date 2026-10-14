class Post {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.cachedAt,
  });

  final int id;
  final int userId;
  final String title;
  final String body;
  final DateTime? cachedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'body': body,
      };

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  Map<String, Object?> toDbMap() => {
        'id': id,
        'payload': '$title|||$body|||$userId',
        'cached_at': (cachedAt ?? DateTime.now()).toIso8601String(),
      };

  factory Post.fromDbMap(Map<String, Object?> map) {
    final payload = map['payload'] as String? ?? '';
    final parts = payload.split('|||');
    final title = parts.isNotEmpty ? parts[0] : '';
    final body = parts.length > 1 ? parts[1] : '';
    final userId = parts.length > 2 ? int.tryParse(parts[2]) ?? 1 : 1;
    final cachedAtStr = map['cached_at'] as String? ?? '';

    return Post(
      id: (map['id'] as num?)?.toInt() ?? 0,
      userId: userId,
      title: title,
      body: body,
      cachedAt: DateTime.tryParse(cachedAtStr),
    );
  }
}
