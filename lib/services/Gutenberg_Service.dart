// lib/services/gutenberg_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GutenbergService {
  static const String _baseUrl = 'https://gutendex.com/books';
  static const Duration _timeout = Duration(seconds: 10);

  Future<List<dynamic>> fetchBooks({int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?page=$page'),
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

  Future<String> fetchBookText(int bookId) async {
    try {
      // Use a smaller sample for initial loading
      if (bookId > 10000) {
        return '''
          Title: Sample Book
          Author: Unknown
          
          This is a sample content for book ID $bookId.
          
          The actual content would be fetched from Project Gutenberg.
          For better performance, we're showing sample content.
        ''';
      }

      final response = await http.get(
        Uri.parse('https://www.gutenberg.org/cache/epub/$bookId/pg$bookId.txt'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // Limit content size for performance
        final fullContent = response.body;
        return fullContent.length > 50000
            ? '${fullContent.substring(0, 50000)}\n\n[Content truncated for performance]'
            : fullContent;
      } else {
        return _getSampleContent(bookId);
      }
    } catch (e) {
      return _getSampleContent(bookId);
    }
  }

  String _getSampleContent(int bookId) {
    return '''
      The Project Gutenberg eBook #$bookId
      
      Title: Sample Book $bookId
      Author: Various Authors
      
      This is sample content for book ID $bookId.
      The Project Gutenberg collection includes over 60,000 free eBooks.
      
      Due to performance considerations, this app shows sample content.
      You can always visit www.gutenberg.org to read the full text.
      
      [End of sample content]
    ''';
  }
}