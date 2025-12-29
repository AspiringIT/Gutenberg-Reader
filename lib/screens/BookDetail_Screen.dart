import 'package:flutter/material.dart';
import '../models/Book.dart';
import 'Reader_Screen.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book title
            Text(
              book.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Authors
            Text(
              'Author(s): ${book.authors.isNotEmpty ? book.authors.join(', ') : 'Unknown'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Publish date
            /*if (book.publishDate != null)
              Text(
                'Published: ${book.publishDate}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),*/

            // Language
            if (book.languages.isNotEmpty)
              Text(
                'Language: ${book.languages.join(', ')}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),

            // Subjects / Genres
            if (book.subjects.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subjects:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: book.subjects
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Summary / Description
            if (book.summary != null && book.summary!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Summary:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.summary!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Rating (if available)
            if (book.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('${book.rating} / 5'),
                ],
              ),

            const SizedBox(height: 32),

            // Read button
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.menu_book),
                label: const Text('Read Book'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReaderScreen(book: book),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
