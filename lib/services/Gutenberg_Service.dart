import 'dart:convert';
import 'package:gutenberg_reader/models/Book.dart';
import 'package:http/http.dart' as http;

class GutenbergService {
  static const Duration _timeout = Duration(seconds: 30);

  Future<List<Book>> fetchBooks({int page = 1}) async {
    try {
      final response = await http
          .get(Uri.parse('https://gutendex.com/books?page=$page'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        return results.map((json) => Book.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<List<Book>> searchBooks(String query, {int page = 1}) async {
    try {
      final url =
          Uri.parse('https://gutendex.com/books?search=$query&page=$page');
      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>;
        return results.map((json) => Book.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to search books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching books: $e');
    }
  }

  Future<void> fetchBookTextWithProgress(
    int bookId, {
    void Function(int loadedBytes, int? totalBytes)? onProgress,
    void Function(String chunk)? onChunk,
  }) async {
    final url = Uri.parse('https://www.gutenberg.org/cache/epub/$bookId/pg$bookId.txt');

    try {
      final request = http.Request('GET', url);
      final streamedResponse = await request.send().timeout(_timeout);

      final totalBytes = streamedResponse.contentLength;
      int loadedBytes = 0;

      await for (var chunkBytes in streamedResponse.stream) {
        loadedBytes += chunkBytes.length;

        if (onChunk != null) {
          final chunkText = utf8.decode(chunkBytes, allowMalformed: true);
          onChunk(chunkText);
        }

        if (onProgress != null) {
          onProgress(loadedBytes, totalBytes);
        }
      }
    } catch (e) {
      if (onChunk != null) {
        onChunk(_getSampleContent(bookId));
      }
      if (onProgress != null) {
        onProgress(0, 0);
      }
    }
  }

  String _getSampleContent(int bookId) {
    return '''
The Project Gutenberg eBook #$bookId

Title: Sample Book $bookId
Author: Various Authors

This is sample content for book ID $bookId.
We were unable to fetch the full text from Project Gutenberg at this time.

Please check your internet connection or try again later.
You can also visit www.gutenberg.org to read the full text.

[End of sample content]
''';
  }
}
