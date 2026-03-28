class Announcement {
  final int id;
  final String title;
  final String content;
  final String? category;
  final DateTime createdAt;
  final String authorName;
  final String? fotoUrl;
  final bool isKegiatan;
  final String? tanggalKegiatan;
  final String? target;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    required this.createdAt,
    required this.authorName,
    this.fotoUrl,
    this.isKegiatan = false,
    this.tanggalKegiatan,
    this.target,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['judul'] ?? json['title'] ?? '',
      content: json['konten'] ?? json['isi'] ?? json['content'] ?? '',
      category: json['kategori'],
      createdAt: DateTime.parse(json['created_at']),
      authorName: json['pembuat_nama'] ?? json['author_name'] ?? 'Admin',
      fotoUrl: json['foto_url'],
      isKegiatan: json['is_kegiatan'] ?? false,
      tanggalKegiatan: json['tanggal_kegiatan'],
      target: json['target'],
    );
  }
}
