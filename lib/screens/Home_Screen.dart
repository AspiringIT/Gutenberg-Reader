import 'package:flutter/material.dart';
import 'package:gutenberg_reader/screens/BookDetail_Screen.dart';
import 'package:gutenberg_reader/screens/GutenbergLicenseScreen.dart';
import 'package:gutenberg_reader/services/Book_Search_Delegate.dart';
import '../models/Book.dart';
import '../services/Gutenberg_Service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GutenbergService _service = GutenbergService();
  List<Book> _books = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  int _currentPage = 1;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _hasError = false;
        _currentPage = 1;
      });
    } else {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final booksData = await _service.fetchBooks(page: _currentPage);
      setState(() {
        if (isRefresh || _currentPage == 1) {
          _books = booksData;
        } else {
          _books.addAll(booksData);
        }
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      if (!isRefresh && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load books: $_errorMessage'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _loadMoreBooks() {
    if (_isLoading || _isRefreshing) return;
    setState(() {
      _currentPage++;
    });
    _fetchBooks();
  }

  void _startSearch() async {
    final result = await showSearch<Book?>(
      context: context,
      delegate: BookSearchDelegate(_service),
    );

    if (result != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookDetailsScreen(book: result),
        ),
      );
    }
  }

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gutenberg Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _openAbout,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchBooks(isRefresh: true),
          ),
        ],
      ),
      body: _isLoading && _books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _hasError && _books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to Load Books',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _fetchBooks(isRefresh: true),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_isRefreshing)
                      const LinearProgressIndicator(minHeight: 2),

                    Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.grey[100],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Showing ${_books.length} books',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => _fetchBooks(isRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _books.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _books.length) {
                              return _buildLoadingIndicator();
                            }

                            final book = _books[index];
                            return _buildBookItem(book, index);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (_isLoading || _isRefreshing) ? null : _loadMoreBooks,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.add),
        label: Text(_isLoading ? 'Loading…' : 'Load More'),
      ),
    );
  }

  Widget _buildBookItem(Book book, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBookColor(index),
          child: Text(
            book.title.substring(0, 1).toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          book.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown Author',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailsScreen(book: book),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Color _getBookColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
