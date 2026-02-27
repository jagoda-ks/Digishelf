import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async{
  
  BookInfo a = await Utils.fetchBook("9786055794804");
  print(a.title);

}

class BookInfo {
  int pageCount;
  String isbn;
  String title;
  String author;
  String pubDate;
  //Uint8List? cover;
  

  BookInfo(this.title, this.author, this.pageCount, this.pubDate, this.isbn);
}

class Utils{
  
  Utils._();

  static const double widthPerPage = 2; //Temp value

  static double getWidth(double pages) => widthPerPage * pages;

  static Future<BookInfo> fetchBook(String isbn) async{
    final results = await http.get(Uri.parse('https://openlibrary.org/isbn/$isbn.json'));
    final Map<String, dynamic> info = jsonDecode(results.body);
    //final cover = results.bodyBytes;
    BookInfo temp = BookInfo(info["title"], 
                             'temp', info["number_of_pages"]??0, info["publish_date"]??0, isbn);
    return temp;
  }

}