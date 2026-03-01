import 'package:flutter/material.dart';
import 'shelf.dart';
import 'pixelate_filter.dart';
import 'book_utils.dart';

void main() {
  runApp(const MyApp());
}

List<double> shelfPos = Utils.getShelfPos();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Constants.updateShelfHeight(MediaQuery.sizeOf(context).height, MediaQuery.sizeOf(context).width);
    shelfPos = Utils.getShelfPos();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PixelateFilter(
        pixelSize: 3.0,
        child: const ShelfPage(title: 'Digishelf'),
      ),
    );
  }
}