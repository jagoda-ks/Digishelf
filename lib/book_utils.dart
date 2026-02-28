import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() async{
  
  BookInfo a = await Utils.fetchBook("9786055794804");
  print(a.cover);

}

class BookInfo {
  double posX = 0;
  double width = Utils.widthPerPage * Utils.defaultPageCount;
  double height = 10;

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


  static const double shelfHeight = 50;
  static const double bookshelfGap = 200;
  static const double widthPerPage = 2; //Temp value
  static const int defaultPageCount = 50; //If returns null
  static List<BookInfo> books = List.empty();

  static double getWidth(double pages) => widthPerPage * pages;

  static Future<BookInfo> fetchBook(String isbn) async{
    final results = await http.get(Uri.parse('https://openlibrary.org/api/books?bibkeys=ISBN:$isbn&jscmd=data&format=json'));
    final Map<String, dynamic> info = jsonDecode(results.body);
    final Map<String, dynamic> infoUnwrapped = info["ISBN:$isbn"];


    final coverResponse = await http.get(Uri.parse(infoUnwrapped["cover"]["small"]));
    final Uint8List coverBytes = coverResponse.bodyBytes;
    BookInfo temp = BookInfo(infoUnwrapped["title"], 
                             infoUnwrapped["authors"][0]["name"], 
                             infoUnwrapped["number_of_pages"]??defaultPageCount, 
                             infoUnwrapped["publish_date"]??"Unknown", 
                             isbn, coverBytes);
    return temp;
  }

}

class Matrix {
    int rows;
    int columns;
    
    List<List<double>>? array;
    
    Matrix (this.rows, this.columns){
        
        array = List.generate(rows, (i) => List<double>.generate(columns, (index) => 0, growable: false), growable: false);
    }
    
    double getVal(int rowIndex, int columnIndex){
        // if (rowIndex >= this.rows || columnIndex >= this.columns){
        //     throw new IndexOutOfBoundsException();
        // }
        
        return this.array![rowIndex][columnIndex];
    }
    
    void setVal(int rowIndex, int columnIndex, double value){
        // if (rowIndex >= this.rows || columnIndex >= this.columns){
        //     throw new IndexOutOfBoundsException();
        // }
        
        this.array![rowIndex][columnIndex] = value;
    }
    
    void setVec(Vector2D vec, int columnIndex){
        // if (this.rows > 2 || columnIndex >= this.columns){
        //     throw new IndexOutOfBoundsException();
        // }
        this.array![0][columnIndex] = vec.x;
        this.array![1][columnIndex] = vec.y;
        
    }
    
    Vector2D getVec(int columnIndex){
        // if (this.rows > 2 || columnIndex >= this.columns){
        //     throw new IndexOutOfBoundsException();
        // }
        
        return Vector2D(this.array![0][columnIndex], this.array![1][columnIndex]);
    }
    
    void setArray(List<List<double>> matrix){
        this.array = List<List<double>>.from(matrix);
    }
    
    Matrix matMul(Matrix matrix){
        // if (this.columns != matrix.rows){
        //     System.err.println("Invalid matrix multiplication with dimensions " + this.rows + "x" + this.columns + " and " + matrix.rows + "x" + matrix.columns);
        //     return null;
        // }
      
        Matrix tempMatrix = Matrix(this.rows, matrix.columns);
        for (int r = 0; r < this.rows; r++){
            for (int c = 0; c < matrix.columns; c++){
                double cell = 0;
                for (int i = 0; i < this.columns; i++) {
                    cell += this.getVal(r, i) * matrix.getVal(i, c);
                }
                tempMatrix.setVal(r, c, cell);
            }
        }
        
        return tempMatrix;
    }
}

class Vector2D {
    double x;
    double y;
    
    Vector2D (this.x, this.y);
    
    Vector2D copy(){
        return Vector2D(this.x, this.y);
    }
    
    Vector2D vectorSum(Vector2D vec){
        this.x += vec.x;
        this.y += vec.y;
        
        return this;
    }
    
    Vector2D scalarMul(double value){
        this.x *= value;
        this.y *= value;
        
        return this;
    }
    
    Vector2D negate(){
        this.x = -this.x;
        this.y = -this.y;
        
        return this;
    }
    
    double dotProduct(Vector2D vec){
        return (this.x * vec.x) + (this.y * vec.y);
    }
    
    double magnitude(){
        return sqrt(pow(this.x, 2) + pow(this.y, 2));
    } 
    
    Vector2D normalise(){
        double norm = this.magnitude();
        this.x /= norm;
        this.y /= norm;
        
        return this;
    }
    
    // Project the vector onto vec2
    double scalarProject(Vector2D vec2, bool normalise) {
        return (normalise) ? this.dotProduct(vec2) / vec2.magnitude() : this.dotProduct(vec2);
    }
    
}