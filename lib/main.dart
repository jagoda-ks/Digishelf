import 'package:flutter/material.dart';
import 'shelf.dart';
import 'pixelate_filter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PixelateFilter(
        pixelSize: 5.0,
        child: const ShelfPage(title: 'Digishelf'),
      ),
    );
  }
}