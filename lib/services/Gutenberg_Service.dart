import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class GutenbergService {
  static const Duration _timeout = Duration(seconds: 30);

  /// Fetch list of books from Gutendex
  Future<List<dynamic>> fetchBooks({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('https://gutendex.com/books?page=$page'),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] as List;
      } else {
        throw Exception('Failed to load books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  /// Fetch full book text in chunks with progress
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
          // Decode UTF-8 safely
          final chunkText = utf8.decode(chunkBytes, allowMalformed: true);
          onChunk(chunkText);
        }

        if (onProgress != null) {
          onProgress(loadedBytes, totalBytes);
        }
      }
    } catch (e) {
      // If download fails, send sample content
      if (onChunk != null) {
        onChunk(_getSampleContent(bookId));
      }
      if (onProgress != null) {
        onProgress(0, 0);
      }
    }
  }

  /// Sample fallback content
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
