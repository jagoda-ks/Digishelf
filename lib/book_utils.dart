// ignore_for_file: unnecessary_this

import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'shelf.dart' as shelf;

void main() async{
  
  BookInfo a = await Utils.fetchBook("9786055794804");
  print(a.location);
  print(a.width);
  BookInfo b = await Utils.fetchBook("9781472154668");
  print(b.location);
  print(b.width);

  //print(Utils.getPos(6132).$1);

}

class BookInfo {
  double location = 0;
  double rot = 0;
  double width = Utils.widthPerPage * Utils.defaultPageCount;
  double height = 8;
  double coveredWidth = 0;
  Vector2D? pos;
  int bookshelfNo = 0;
  Vector2D? boundaries;

  int pageCount;
  String isbn;
  String title;
  String author;
  String pubDate;
  Uint8List? cover;
  

  BookInfo(this.title, this.author, this.pageCount, this.pubDate, this.isbn, this.cover){
    this.width = Utils.getWidth(pageCount);
    this.coveredWidth = this.width;
    this.location = Utils.getNextAvailablePos(this.width);
    this.boundaries = Vector2D(location, this.location+width);
    var tmp = Utils.getPos(this.location);
    this.bookshelfNo = tmp.$3;
    this.pos = Vector2D(tmp.$1, tmp.$2);
    Random random = Random();
    this.height += random.nextDouble() * 4;
    Utils.books.add(this);
  }
}

class Constants{
  static double height = 0;
  static double width = 0;
  static double shelfHeight = 0;
  static const shelfCount = 4;
  static const marginXMultiplier = 0.08;

  static double initialXMargin = 80;
  static double initialYMargin = 20;

  static void updateShelfHeight(double screenHeight, double screenWidth){
    height = screenHeight;
    width = screenWidth;
    shelfHeight = (screenHeight - 2*initialYMargin)/shelfCount;
    initialXMargin = (screenWidth * marginXMultiplier);
  }
}

class Utils{
  
  Utils._();
  
  static const double bookshelfGap = 200;
  static const double shelfThreshold = 100;
  static const double bookshelfThreshold = 200;
  static const double accuracyMeasure = 1e-4;

  static const double widthPerPage = 2; //Temp value
  static const int defaultPageCount = 50; //If returns null
  static List<BookInfo> books = List.empty(growable: true);
  static List<double> regionAvailability = List.empty(growable: true);

  static double getWidth(int pages) => widthPerPage * pages;

  static double adjustYWithRot() => Constants.shelfHeight;

  static double getNextAvailablePos(double width){
    if (regionAvailability.isEmpty){
      regionAvailability.add(0);
      regionAvailability.add(width);
      return 0;
    }

    bool isAvailable = true;

    for (int i = 0; i < regionAvailability.length-1; i++){
      isAvailable = !isAvailable;
      if (isAvailable && regionAvailability[i+1] - regionAvailability[i] > width){
        _updateBoundary(Vector2D(regionAvailability[i], regionAvailability[i] + width));
        return regionAvailability[i];
      }
    }

    return regionAvailability[regionAvailability.length-1];
  }

  static bool spaceAvailable(double location, double width){
    if (regionAvailability.isEmpty){
      return true;
    }

    bool isAvailable = true;

    for (int i = 0; i < regionAvailability.length-1; i++){
      isAvailable = !isAvailable;
      if (regionAvailability[i] > location){
        if (isAvailable && regionAvailability[i] - regionAvailability[i-1] > width){
          return true;
        }
      }
    }

    return (isAvailable) ? true : false;
  }

  static void _updateBoundary(Vector2D boundaryVec){
    int toRemoveX = -1;
    int toRemoveY = -1;
    for(int i = 0; i<regionAvailability.length; i++){
      if(regionAvailability[i] - boundaryVec.x < accuracyMeasure){
        toRemoveX = i;
      }
      else if (regionAvailability[i] - boundaryVec.y < accuracyMeasure){
        toRemoveY = i;
      }
    }

    if (toRemoveX == -1) { regionAvailability.add(boundaryVec.x); }
    else { regionAvailability.removeAt(toRemoveX); }

    if (toRemoveY == -1) { regionAvailability.add(boundaryVec.y); }
    else { regionAvailability.removeAt(toRemoveY); }
  }

  static (double x, double y, int bookshelfNo) getPos(double location){
    int tempNo = location ~/ bookshelfThreshold;
    location = location % bookshelfThreshold;
    double tempY = ((location ~/ shelfThreshold) + 1) * Constants.shelfHeight;
    double tempX = location % shelfThreshold;
    return (Constants.initialXMargin + tempX, Constants.initialYMargin + tempY, tempNo);
  }

  static (double x, double y) getClosestPos(double x, double y, double width){
    double tmpX = Utils.clamp(x, Constants.initialXMargin, 
        (Constants.width * (1 - Constants.marginXMultiplier))-width-Constants.initialXMargin);
    double tmpY = (((((y-Constants.initialYMargin).clamp(
      Constants.initialYMargin+Constants.shelfHeight, Constants.shelfCount * Constants.shelfHeight) 
                + Constants.shelfHeight / 2) ~/ Constants.shelfHeight)) * Constants.shelfHeight) + Constants.initialYMargin;
    return (tmpX, tmpY);
  }

  static double toLocation(double x, double y, int bookshelfNo){
    int shelf = ((y - Constants.initialYMargin) ~/ Constants.shelfHeight);
    return x + (shelf * shelfThreshold) + (bookshelfNo * bookshelfThreshold);
  }

  static Vector2D updatePos(BookInfo book, Offset endPos, int bookshelfNo){
    book.bookshelfNo = bookshelfNo;
    var tmp = getClosestPos(endPos.dx, endPos.dy, book.width);
    book.pos = Vector2D(tmp.$1, tmp.$2);
    double numericX = ((book.pos!.x - Constants.initialXMargin)/(Constants.width * 2 * Constants.marginXMultiplier))*shelfThreshold;
    book.location = toLocation(numericX, book.pos!.y, bookshelfNo);
    return Vector2D(book.pos!.x, book.pos!.y);
  }

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

  static double clamp(double variable, double min, double max){
        if (variable <= max && variable >= min){return variable;}
        else if (variable > max) {return max;}
        else {return min;}
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