import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async{
  
  BookInfo a = await Utils.fetchBook("9786055794804");
  print(a.pubDate);

}

class BookInfo {
  int pageCount;
  String isbn;
  String title;
  String author;
  String pubDate;
  Uint8List? cover;
  

  BookInfo(this.title, this.author, this.pageCount, this.pubDate, this.isbn, this.cover);
}

class Utils{
  
  Utils._();

  static const double widthPerPage = 2; //Temp value
  static const int defaultPageCount = 50; //If returns null

  static double getWidth(double pages) => widthPerPage * pages;

  static Future<BookInfo> fetchBook(String isbn) async{
    final results = await http.get(Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&jscmd=data&format=json'));
    final Map<String, dynamic> info = jsonDecode(results.body);
    final Map<String, dynamic> infoUnwrapped = info["ISBN:$isbn"];


    final coverResponse = await http.get(Uri.parse(infoUnwrapped["cover"]["medium"]));
    final Uint8List coverBytes = coverResponse.bodyBytes;
    BookInfo temp = BookInfo(infoUnwrapped["title"], 
                             infoUnwrapped["authors"][0]["name"], 
                             infoUnwrapped["number_of_pages"]??defaultPageCount, 
                             infoUnwrapped["publish_date"]??"Unknown", 
                             isbn, coverBytes);
    return temp;
  }

}