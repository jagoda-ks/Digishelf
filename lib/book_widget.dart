import 'package:flutter/material.dart';

class BookWidget extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  
  const BookWidget({
    super.key, 
    required this.title,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Image(
        image: ResizeImage(
          AssetImage('assets/book.png'),
          width: 40,
          height: 60,
        ),
        filterQuality: FilterQuality.none,
        fit: BoxFit.fill,
      ),
    );
  }
}