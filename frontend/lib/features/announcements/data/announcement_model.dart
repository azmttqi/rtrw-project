class Announcement {
  final int id;
  final String title;
  final String content;
  final String? category;
  final DateTime createdAt;
  final String authorName;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.createdAt,
    required this.authorName,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['judul'] ?? json['title'],
      content: json['konten'] ?? json['isi'] ?? json['content'],
      category: json['kategori'],
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['pembuat_nama'] ?? json['author_name'] ?? 'Admin',
    );
  }
}
