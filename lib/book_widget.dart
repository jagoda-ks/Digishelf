import 'package:flutter/material.dart';

class BookWidget extends StatelessWidget {
  final String title;
  final double width;
  final double height;
  final VoidCallback? onTap;
  
  const BookWidget({
    super.key, 
    required this.title,
    required this.width,
    required this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        print('Tapped on $title');
      },
      child: SizedBox(
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
      ),
    );
  }
}