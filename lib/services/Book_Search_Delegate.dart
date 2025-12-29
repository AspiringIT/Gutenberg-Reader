import 'package:flutter/material.dart';
import '../models/Book.dart';
import '../services/Gutenberg_Service.dart';
import '../main.dart'; // for navigatorKey

class BookSearchDelegate extends SearchDelegate<Book?> {
  final GutenbergService service;

  BookSearchDelegate(this.service);

  int _currentPage = 1;
  List<Book> _books = [];
  bool _isLoadingMore = false;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            _books.clear();
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  Future<void> _fetchSearchResults({bool isRefresh = false}) async {
    if (query.isEmpty) return;

    if (isRefresh) _currentPage = 1;

    try {
      final results = await service.searchBooks(query, page: _currentPage);
      if (isRefresh) {
        _books = results;
      } else {
        _books.addAll(results);
      }
    } catch (e) {
      if (navigatorKey.currentContext?.mounted ?? false) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(content: Text('Error searching books: $e')),
        );
      }
      rethrow;
    }
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type something to search'));
    }

    return FutureBuilder<void>(
      future: _fetchSearchResults(isRefresh: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              textAlign: TextAlign.center,
            ),
          );
        } else if (_books.isEmpty) {
          return const Center(child: Text('No results found'));
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 100 &&
                !_isLoadingMore) {
              _isLoadingMore = true;
              _currentPage++;
              _fetchSearchResults().then((_) {
                _isLoadingMore = false;
                if (context.mounted) {
                  (context as Element).markNeedsBuild();
                }
              });
            }
            return false;
          },
          child: ListView.builder(
            itemCount: _books.length + (_isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _books.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final book = _books[index];
              return ListTile(
                title: Text(book.title),
                subtitle: Text(book.authors.isNotEmpty
                    ? book.authors.join(', ')
                    : 'Unknown Author'),
                onTap: () => close(context, book),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Type to search books'));
  }
}
