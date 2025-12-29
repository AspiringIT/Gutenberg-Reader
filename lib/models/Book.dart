class Book {
  final int id;
  final String title;
  final List<String> authors;
  final List<String> subjects;
  final String? downloadUrl;
  final String? coverUrl;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.subjects,
    this.downloadUrl,
    this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      authors: List<String>.from(
        (json['authors'] ?? []).map((author) => author['name'] ?? 'Unknown Author'),
      ),
      subjects: List<String>.from(json['subjects'] ?? []),
      downloadUrl: json['formats']?['text/plain; charset=utf-8'] ??
          json['formats']?['text/plain'],
      coverUrl: json['formats']?['image/jpeg'],
    );
  }
}