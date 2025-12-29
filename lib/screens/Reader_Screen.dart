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
  String _content = '';
  bool _isLoading = true;
  double _fontSize = 16.0;
  ThemeData _currentTheme = AppThemes.lightTheme;

  @override
  void initState() {
    super.initState();
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      final content = await _service.fetchBookText(widget.book.id);
      setState(() {
        _content = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _content = 'Error loading book content: $e';
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
          title: Text(widget.book.title),
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
                  value: 14.0,
                  child: Text('Small'),
                ),
                const PopupMenuItem(
                  value: 16.0,
                  child: Text('Medium'),
                ),
                const PopupMenuItem(
                  value: 18.0,
                  child: Text('Large'),
                ),
                const PopupMenuItem(
                  value: 20.0,
                  child: Text('Extra Large'),
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.book.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'By ${widget.book.authors.join(', ')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(height: 32),
                Text(
                  _content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement download functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Downloading book...')),
            );
          },
          child: const Icon(Icons.download),
        ),
      ),
    );
  }
}