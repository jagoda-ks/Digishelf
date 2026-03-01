import 'book_utils.dart';

class PlacementManager {

  PlacementManager._();

  static List<double> regionAvailability = List.empty(growable: true);

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

  static double getNextAvailablePos(double width){
    if (regionAvailability.isEmpty){
      PlacementManager.addBoundaries(0);
      regionAvailability.add(0);
      regionAvailability.add(width);
      
      return 0;
    }

    bool isAvailable = (regionAvailability.length % 2 == 0);

    for (int i = 0; i < regionAvailability.length-1; i++){
      isAvailable = !isAvailable;
      if (isAvailable && regionAvailability[i+1] - regionAvailability[i] > width){
        _updateBoundary(Vector2D(regionAvailability[i], regionAvailability[i] + width));
        return regionAvailability[i];
      }
    }

    double temp = regionAvailability[regionAvailability.length-1];
    _updateBoundary(Vector2D(temp, temp + width));
    return temp;
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

    print(regionAvailability.toString());
  }

  static void addBoundaries(int bookshelfNo){
    double composite = (Constants.width * (1 - Constants.marginXMultiplier))-Constants.initialXMargin*1.1;
    double edge = composite + (Utils.bookshelfThreshold * (bookshelfNo));
    for (int i = 0; i < Constants.shelfCount; i++){
      _updateBoundary(Vector2D(edge, edge + 1));
      edge +=  composite;
    }
  }
}