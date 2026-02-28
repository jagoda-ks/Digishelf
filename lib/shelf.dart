import 'package:flutter/material.dart';
import 'book_utils.dart';
import 'book_widget.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.title});
  final String title;

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {

  final List<List<BookInfo>> shelves = [

    [
      BookInfo("Book A", "cillian", 200, "2020", "3932850238", null),
      BookInfo("Book B", "cillian", 120, "2021", "1234567890", null),
    ],

    [
      BookInfo("Book C", "cillian", 180, "2022", "9999999999", null),
      BookInfo("Book D", "cillian", 90, "2023", "8888888888", null),
    ],

  ];

  Widget buildShelf(List<BookInfo> books) {
    return Center(
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).width * 1.5,

        child: Stack(
          children: [

            Positioned.fill(
              child: Image.asset(
                'assets/shelf.png',
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),

            ...books.map((book) {

              var booksPlace = Utils.getPos(book.location);

              return Positioned(
                left: booksPlace.$1,
                top: booksPlace.$2,

                child: BookWidget(
                  title: book.title,
                  width: book.width,
                  height: 100,
                ),
              );

            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: PageView.builder(

        scrollDirection: Axis.horizontal,

        itemCount: shelves.length,

        itemBuilder: (context, index) {

          return buildShelf(shelves[index]);

        },

      ),

    );
  }
}