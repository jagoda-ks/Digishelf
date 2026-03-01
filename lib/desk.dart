import 'package:flutter/material.dart';
import 'book_utils.dart';
import 'book_widget.dart';

class DeskPage extends StatelessWidget {
  final BookInfo book;

  const DeskPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D2314),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C1810),
        foregroundColor: Colors.white,
        title: Text(book.title),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BookWidget(
              title: book.title,
              width: 120,
              height: 180,
            ),
            const SizedBox(height: 32),
            Text(
              book.author,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'ISBN: \${book.isbn}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}