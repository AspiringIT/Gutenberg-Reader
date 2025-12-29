import 'dart:convert';
import 'package:http/http.dart' as http;

class GutenbergService {
  static const String _baseUrl = 'https://gutendex.com/books';

  Future<List<dynamic>> fetchBooks({int page = 1}) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?page=$page'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['results'] as List;
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<String> fetchBookText(int bookId) async {
    try {
      // For demonstration, using a sample text
      final response = await http.get(
          Uri.parse('https://www.gutenberg.org/cache/epub/$bookId/pg$bookId.txt')
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        // Fallback to sample text
        return '''
          The Project Gutenberg eBook of Sample Book
          
          This is a sample book content for demonstration purposes.
          
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
          Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
        ''';
      }
    } catch (e) {
      return 'Error loading book content. Please try again later.';
    }
  }
}