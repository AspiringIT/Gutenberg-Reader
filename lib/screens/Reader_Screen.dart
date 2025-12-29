import 'package:flutter/material.dart';
import '../app/Theme.dart';
import '../models/Book.dart';
import '../services/Gutenberg_Service.dart';

enum TextLayout { left, justify, center, right }

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final GutenbergService _service = GutenbergService();
  List<String> _paragraphs = [];
  bool _isLoading = true;
  double _fontSize = 18.0;
  ThemeData _currentTheme = AppThemes.lightTheme;
  TextLayout _textLayout = TextLayout.left;
  final ScrollController _scrollController = ScrollController();

  // Progress tracking
  int _loadedBytes = 0;
  int? _totalBytes;

  // Store last selected layout for all books
  static TextLayout lastSelectedLayout = TextLayout.left;

  @override
  void initState() {
    super.initState();
    _textLayout = lastSelectedLayout; // Load last used layout
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
      _paragraphs.clear();
      _loadedBytes = 0;
      _totalBytes = null;
    });

    try {
      await _service.fetchBookTextWithProgress(
        widget.book.id,
        onProgress: (loaded, total) {
          setState(() {
            _loadedBytes = loaded;
            _totalBytes = total;
          });
        },
        onChunk: (chunk) {
          final newParagraphs = chunk
              .split(RegExp(r'\n\s*\n'))
              .where((p) => p.trim().isNotEmpty)
              .toList();
          setState(() {
            _paragraphs.addAll(newParagraphs);
          });
        },
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _paragraphs = [
          'Failed to load content. Please try again later.\n\nError: $e'
        ];
        _isLoading = false;
      });
    }
  }

  void _changeTheme(ThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
  }

  TextAlign _getTextAlign() {
    switch (_textLayout) {
      case TextLayout.justify:
        return TextAlign.justify;
      case TextLayout.center:
        return TextAlign.center;
      case TextLayout.right:
        return TextAlign.end;
      case TextLayout.left:
      default:
        return TextAlign.start;
    }
  }

  Future<void> _scrollSmoothly(double target) async {
    if (!_scrollController.hasClients) return;

    const step = 300.0; 
    const delay = Duration(milliseconds: 5);

    double current = _scrollController.offset;
    final direction = target > current ? 1 : -1;

    while ((direction == 1 && current < target) ||
        (direction == -1 && current > target)) {
      current += step * direction;

      if (direction == 1 && current > target) current = target;
      if (direction == -1 && current < target) current = target;

      _scrollController.jumpTo(current);
      await Future.delayed(delay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = (_totalBytes != null && _totalBytes! > 0)
        ? _loadedBytes / _totalBytes!
        : null;

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
            // Theme selection
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
                  child: const Row(
                    children: [
                      Icon(Icons.invert_colors, color: Color(0xFF5B4636)),
                      SizedBox(width: 8),
                      Text('Sepia'),
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
            // Font size
            PopupMenuButton<double>(
              icon: const Icon(Icons.text_fields),
              onSelected: (value) {
                setState(() {
                  _fontSize = value;
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 16.0, child: Text('Small')),
                PopupMenuItem(value: 18.0, child: Text('Medium')),
                PopupMenuItem(value: 20.0, child: Text('Large')),
                PopupMenuItem(value: 22.0, child: Text('Extra Large')),
              ],
            ),
            // Text layout
            PopupMenuButton<TextLayout>(
              icon: const Icon(Icons.format_align_left),
              onSelected: (value) {
                setState(() {
                  _textLayout = value;
                  lastSelectedLayout = value; // Save last selection
                });
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: TextLayout.left, child: Text('Left')),
                PopupMenuItem(value: TextLayout.justify, child: Text('Justify')),
                PopupMenuItem(value: TextLayout.center, child: Text('Center')),
                PopupMenuItem(value: TextLayout.right, child: Text('Right')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 4,
                ),
              ),
            Expanded(
              child: _paragraphs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _paragraphs.length + 3,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              widget.book.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else if (index == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              children: [
                                Text(
                                  'By ${widget.book.authors.join(', ')}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Divider(),
                              ],
                            ),
                          );
                        } else if (index <= _paragraphs.length + 1) {
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal:
                                  _textLayout == TextLayout.justify ? 16 : 8,
                            ),
                            child: Text(
                              _paragraphs[index - 2],
                              style: TextStyle(
                                fontSize: _fontSize,
                                height: 1.6,
                              ),
                              textAlign: _getTextAlign(),
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 48.0),
                            child: Text(
                              '--- END OF BOOK ---',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic),
                            ),
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton.small(
              heroTag: 'scroll_top',
              onPressed: () => _scrollSmoothly(0),
              child: const Icon(Icons.arrow_upward),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              heroTag: 'scroll_bottom',
              onPressed: () => _scrollSmoothly(
                  _scrollController.position.maxScrollExtent),
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
