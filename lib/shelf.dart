import 'package:flutter/material.dart';
import 'book_widget.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.title});
  final String title;

  @override
  State<ShelfPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ShelfPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          height: 600,
          child: Stack(
            children: [
              // Shelf background
              Image(
                image: ResizeImage(
                  AssetImage('assets/shelf.png'),
                  width: 40,
                  height: 60,
                ),
                filterQuality: FilterQuality.none,
                fit: BoxFit.fill,
                width: 400,
                height: 600,
              ),
              // Books aligned to bottom
              Padding(
                padding: const EdgeInsets.all(30),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 30.0,
                  crossAxisAlignment: WrapCrossAlignment.end,
                  children: [
                    BookWidget(title: 'Book 1', width: 50, height: 100),
                    BookWidget(title: 'Book 2', width: 80, height: 80),
                    BookWidget(title: 'Book 3', width: 60, height: 120),
                    BookWidget(title: 'Book 4', width: 120, height: 90),
                    BookWidget(title: 'Book 5', width: 40, height: 100),
                    BookWidget(title: 'Book 1', width: 50, height: 100),
                    BookWidget(title: 'Book 2', width: 80, height: 80),
                    BookWidget(title: 'Book 3', width: 60, height: 120),
                    BookWidget(title: 'Book 4', width: 120, height: 90),
                    BookWidget(title: 'Book 5', width: 40, height: 100),
                    BookWidget(title: 'Book 1', width: 50, height: 100),
                    BookWidget(title: 'Book 2', width: 80, height: 80),
                    BookWidget(title: 'Book 3', width: 60, height: 120),
                    BookWidget(title: 'Book 4', width: 120, height: 90),
                    BookWidget(title: 'Book 5', width: 40, height: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}