import 'book_utils.dart';

class PlacementManager {

  PlacementManager._();

  static List<double> regionAvailability = List.filled(1, 0, growable: true);
  static List<double> borders = List.empty(growable: true);

  static bool spaceAvailable(double location, double width){
    if (regionAvailability.isEmpty){
      return true;
    }

    bool isAvailable = (regionAvailability.length % 2 != 0);

    for (int i = 0; i < regionAvailability.length-1; i++){
      if (regionAvailability[i] > location){
        if (isAvailable && regionAvailability[i] - regionAvailability[i-1] > width){
          return true;
        }
      }
      isAvailable = !isAvailable;
    }

    return (isAvailable) ? true : false;
  }

  /// For newly created books and updating the last book.
  static double getInitialAvailablePos(double width, [double startPos = 0]){
    if (regionAvailability.isEmpty){
      return 0;
    }

    bool isAvailable = (regionAvailability.length % 2 != 0);

    for (int i = 0; i < regionAvailability.length-1; i++){
      if ((regionAvailability[i] - startPos) >= -Constants.accuracyMeasure && isAvailable && regionAvailability[i+1] - regionAvailability[i] > width){
        double pos = regionAvailability[i];
        _updateBoundary(Vector2D(pos, pos + width));
        return pos;
      }
      isAvailable = !isAvailable;
    }

    double temp = (spaceAvailable(startPos, width) && startPos > regionAvailability[regionAvailability.length-1]) ?
                                                        startPos : regionAvailability[regionAvailability.length-1];
    _updateBoundary(Vector2D(temp, temp + width));
    return temp;
  }

  /// For already existing books to update their positions.
  static double getNextAvailablePos(double width, double startPos, double endPos){
    if (regionAvailability.isEmpty){
      return 0;
    }

    return 0.0;
  }

  static void _updateBoundary(Vector2D boundaryVec){
    int toRemoveX = -1;
    int toRemoveY = -1;
    for(int i = 0; i<regionAvailability.length; i++){
      if((regionAvailability[i] - boundaryVec.x).abs() < Constants.accuracyMeasure){
        toRemoveX = i;
      }
      else if ((regionAvailability[i] - boundaryVec.y).abs() < Constants.accuracyMeasure){
        toRemoveY = i;
      }
    }

    if(toRemoveX != 0){
      if (toRemoveX == -1) { regionAvailability.add(boundaryVec.x); }
      else { regionAvailability.removeAt(toRemoveX); }
    }

    if(toRemoveY != 0){
      if (toRemoveY == -1) { regionAvailability.add(boundaryVec.y); }
      else { regionAvailability.removeAt(toRemoveY); }
    }

    regionAvailability.sort();
  }

  static void placeBook(int index, BookInfo book){

    BookInfo a = Utils.books[index-1];
    BookInfo b = Utils.books[index];
    if (b.location > book.location){
        if (book.location >= a.location + a.width && book.location + book.width <= b.location){
          PlacementManager._updateBoundary(Vector2D(book.location, book.location + book.width));
        }
        else if (book.location < a.location + a.width){

        }
        else {
          
        }
      }
  }

  static void addBoundaries(int bookshelfNo){
    double edge = Utils.bookshelfThreshold * bookshelfNo;
    for (int i = 0; i < Constants.shelfCount; i++){
      edge += Utils.shelfThreshold;
      _updateBoundary(Vector2D(edge - 1, edge)); // wall boundary at end of each shelf
      borders.add(edge-1);
      borders.add(edge);
    }
    borders.sort();
  }
}