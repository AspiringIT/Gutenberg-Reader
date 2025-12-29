import 'package:flutter/material.dart';
import '../app/Theme.dart';
import '../models/Book.dart';
import '../services/Gutenberg_Service.dart';


class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final GutenbergService _service = GutenbergService();
  String _content = 'Loading...';
  bool _isLoading = true;
  double _fontSize = 18.0;
  ThemeData _currentTheme = AppThemes.lightTheme;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBookContent() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final content = await _service.fetchBookText(widget.book.id);
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Failed to load content. Please try again later.\n\nError: $e';
        _isLoading = false;
      });
    }
  }

  void _changeTheme(ThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _currentTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.book.title.length > 20
                ? '${widget.book.title.substring(0, 20)}...'
                : widget.book.title,
          ),
          actions: [
            PopupMenuButton<ThemeData>(
              icon: const Icon(Icons.palette),
              onSelected: _changeTheme,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: AppThemes.lightTheme,
                  child: Row(
                    children: [
                      Icon(Icons.light_mode, color: Colors.grey[800]),
                      const SizedBox(width: 8),
                      const Text('Light'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: AppThemes.sepiaTheme,
                  child: Row(
                    children: [
                      Icon(Icons.invert_colors, color: const Color(0xFF5B4636)),
                      const SizedBox(width: 8),
                      const Text('Sepia'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: AppThemes.darkTheme,
                  child: Row(
                    children: [
                      Icon(Icons.dark_mode, color: Colors.grey[300]),
                      const SizedBox(width: 8),
                      const Text('Dark'),
                    ],
                  ),
                ),
              ],
            ),
            PopupMenuButton<double>(
              icon: const Icon(Icons.text_fields),
              onSelected: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 16.0,
                  child: Text('Small'),
                ),
                const PopupMenuItem(
                  value: 18.0,
                  child: Text('Medium'),
                ),
                const PopupMenuItem(
                  value: 20.0,
                  child: Text('Large'),
                ),
                const PopupMenuItem(
                  value: 22.0,
                  child: Text('Extra Large'),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading book content...'),
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            controller: _scrollController,
            children: [
              // Book title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Author
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'By ${widget.book.authors.join(', ')}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),

              const Divider(),

              // Content
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  _content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.6,
                  ),
                ),
              ),

              // End of book indicator
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text(
                  '--- END ---',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 'scroll_top',
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'scroll_bottom',
              onPressed: () {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              child: const Icon(Icons.arrow_downward),
            ),
            const SizedBox(height: 8),
            FloatingActionButton(
              heroTag: 'download',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Download feature coming soon!')),
                );
              },
              child: const Icon(Icons.download),
            ),
          ],
        ),
      ),
    );
  }
}