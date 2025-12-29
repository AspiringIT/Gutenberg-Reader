class Book {
  final int id;
  final String title;
  final List<String> authors;
  final List<String> languages;
  final List<String> subjects;
  final String? summary;
  final String? publishDate;
  final double? rating;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    this.languages = const [],
    this.subjects = const [],
    this.summary,
    this.publishDate,
    this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['title'] ?? 'Untitled',
      authors: (json['authors'] as List<dynamic>)
          .map((a) => a['name'] as String)
          .toList(),
      languages: (json['languages'] as List<dynamic>?)
              ?.map((l) => l.toString())
              .toList() ??
          [],
      subjects: (json['subjects'] as List<dynamic>?)
              ?.map((s) => s.toString())
              .toList() ??
          [],
      summary: json['summary'] as String?, // Gutendex may not provide
      publishDate: json['download_count'] != null
          ? json['download_count'].toString() // replace with real date if available
          : null,
      rating: null, // Gutendex does not provide ratings directly
    );
  }
}
