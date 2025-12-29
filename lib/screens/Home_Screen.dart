import 'package:flutter/material.dart';
import '../models/Book.dart';
import '../services/Gutenberg_Service.dart';
import 'Reader_Screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GutenbergService _service = GutenbergService();
  List<Book> _books = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _showWelcome = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();

    // Hide welcome message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  Future<void> _fetchBooks() async {
    try {
      final booksData = await _service.fetchBooks(page: _currentPage);
      setState(() {
        _books = booksData.map((json) => Book.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gutenberg Reader'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // TODO: Add drawer menu
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // TODO: Add profile/settings
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome banner
          if (_showWelcome)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _showWelcome ? 80 : 0,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 40,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Gutenberg Reader!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Start your reading journey with free books',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showWelcome = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Stats row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  context,
                  icon: Icons.library_books,
                  value: '60,000+',
                  label: 'Free Books',
                  color: Colors.blue,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.language,
                  value: '100+',
                  label: 'Languages',
                  color: Colors.green,
                ),
                _buildStatCard(
                  context,
                  icon: Icons.history_edu,
                  value: '500+',
                  label: 'Authors',
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          // Featured section header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Books',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show all books
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),

          // Book list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No books found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchBooks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _currentPage = 1;
                });
                await _fetchBooks();
              },
              child: ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return _buildBookCard(context, book, index);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _currentPage++;
            _fetchBooks();
          });
        },
        icon: const Icon(Icons.explore),
        label: const Text('Explore More'),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(BuildContext context, Book book, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReaderScreen(book: book),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _getBookColor(index),
                    borderRadius: BorderRadius.circular(8),
                    image: book.coverUrl != null
                        ? DecorationImage(
                      image: NetworkImage(book.coverUrl!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: book.coverUrl == null
                      ? Center(
                    child: Icon(
                      Icons.book,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
                      : null,
                ),

                const SizedBox(width: 16),

                // Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        book.authors.join(', '),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      if (book.subjects.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: book.subjects.take(2).map((subject) {
                            return Chip(
                              label: Text(
                                subject.length > 15
                                    ? '${subject.substring(0, 15)}...'
                                    : subject,
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: Colors.grey.shade100,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                // Action button
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReaderScreen(book: book),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBookColor(int index) {
    final colors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.red.shade700,
      Colors.teal.shade700,
    ];
    return colors[index % colors.length];
  }
}