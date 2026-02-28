import 'package:flutter/material.dart';
import 'book_widget.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.title});
  final String title;

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class Item {
  double x;
  double y;
  final double bookWidth;
  final String label;

  Item(this.x, this.y, this.bookWidth, this.label);
}

class _ShelfPageState extends State<ShelfPage> {

  final List<Item> items = [ // items should probable be named books. also i spelt probaly wrong
    Item(0, 0, 10, "Book A"),
    Item(40, 0, 20, "Book D"),
    Item(70, 0, 30, "Book E"),
    Item(110, 0, 10, "Book F"),
    Item(140, 0, 30, "Book G"),
    Item(50, 120, 40, "Book H"),
  ];

  double adjusted(double value) {
    if (value % 100 == 0 && value != 0) {
      return value + 50;
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 400,
        height: 300,

        child: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/shelf.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),

            ...items.asMap().entries.map((entry) {

              int index = entry.key;
              Item item = entry.value;

              return Positioned(
                left: item.x,
                top: item.y,

                child: GestureDetector(

                  onPanUpdate: (details) {
                    setState(() {
                      item.x += details.delta.dx; // send this to ulas he will figure it out
                      item.y += details.delta.dy;
                    });
                  },

                  child: BookWidget(
                    title: item.label,
                    width: item.bookWidth,
                    height: 100,
                  ),
                ),
              );
            }),

          ],
        ),
      ),
    );
  }
}