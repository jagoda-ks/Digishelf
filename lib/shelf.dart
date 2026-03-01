import 'dart:ui';

import 'package:flutter/material.dart';
import 'book_utils.dart';
import 'book_widget.dart';
import 'desk.dart';
import 'package:flutter/scheduler.dart';
import 'main.dart';

class ShelfPage extends StatefulWidget {
  const ShelfPage({super.key, required this.title});
  final String title;

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _DragPhysics {
  Offset targetPosition;
  Offset displayPosition;
  Offset velocity = Offset.zero;
  Offset _lastTarget;
  DateTime _lastTime = DateTime.now();

  _DragPhysics(Offset start)
      : targetPosition = start,
        displayPosition = start,
        _lastTarget = start;

  void update(Offset newTarget) {
    final now = DateTime.now();
    final dt = now.difference(_lastTime).inMicroseconds / 1000000.0;
    if (dt > 0) {
      velocity = (newTarget - _lastTarget) / dt;
    }
    _lastTarget = newTarget;
    _lastTime = now;
    targetPosition = newTarget;
  }

  void tick(Duration elapsed) {
    const double stiffness = 24.0;
    const double damping = 0.1;

    final diff = targetPosition - displayPosition;
    displayPosition = displayPosition + diff * (1 - damping) * stiffness * 0.016;
  }

  double get tiltAngle {
    final lag = targetPosition.dx - displayPosition.dx;
    return (lag / 120).clamp(-0.35, 0.35);
  }
}



List<(String asset, double top)> _shelfPlanks = [
  ('assets/Shelf4.png', shelfPos[0]),
  ('assets/Shelf2.png', shelfPos[1]),
  ('assets/Shelf3.png', shelfPos[2]),
];

class _ShelfPageState extends State<ShelfPage> with SingleTickerProviderStateMixin {
  final List<List<BookInfo>> shelves = _buildShelves();

  BookInfo? _heldBook;
  Offset _dragPosition = Offset.zero;

  _DragPhysics? _physics;
  late final Ticker _ticker;

  bool _isOverDropZone = false;
  bool _hasDragged = false;

@override
void initState() {
  super.initState();
  _ticker = createTicker((_elapsed) {
    if (_physics != null) {
      setState(() {
        _physics!.tick(_elapsed);
      });
    }
  });
}

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  static List<List<BookInfo>> _buildShelves() {
    final List<List<BookInfo>> result = [];

    // Each BookInfo(title, author, pageCount, pubDate, isbn, cover)
    // width is computed inside BookInfo as: Utils.getWidth(pageCount)
    // which equals Utils.widthPerPage * pageCount (2.0 * pages)
    Utils.books.clear();
    Utils.regionAvailability.clear();
    result.add([
      BookInfo("The Hobbit",              "J.R.R. Tolkien",   310, "1937", "9780261102217", null),
      BookInfo("1984",                    "George Orwell",    328, "1949", "9780451524935", null),
      BookInfo("Dune",                    "Frank Herbert",    688, "1965", "9780441013593", null),
      BookInfo("Fahrenheit 451",          "Ray Bradbury",     158, "1953", "9781451673319", null),
      BookInfo("Brave New World",         "Aldous Huxley",    311, "1932", "9780060850524", null),
      BookInfo("The Great Gatsby",        "F. Scott Fitzgerald", 180, "1925", "9780743273565", null),
      BookInfo("To Kill a Mockingbird",   "Harper Lee",       281, "1960", "9780061120084", null),
      BookInfo("Crime and Punishment",    "Fyodor Dostoevsky",551, "1866", "9780679720201", null),
      BookInfo("The Odyssey",             "Homer",            374, "800BC","9780140449136", null),
      BookInfo("Pride and Prejudice",     "Jane Austen",      432, "1813", "9780141439518", null),
    ]);

    Utils.books.clear();
    Utils.regionAvailability.clear();
    result.add([
      BookInfo("Harry Potter 1",          "J.K. Rowling",     309, "1997", "9780439708180", null),
      BookInfo("The Hunger Games",        "Suzanne Collins",  374, "2008", "9780439023481", null),
      BookInfo("The Road",                "Cormac McCarthy",  287, "2006", "9780307277671", null),
      BookInfo("Ender's Game",            "Orson Scott Card", 352, "1985", "9780812550702", null),
      BookInfo("The Alchemist",           "Paulo Coelho",     208, "1988", "9780062315007", null),
    ]);

    return result;
  }

  bool _isInDropZone(Offset globalPosition) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return globalPosition.dy >= screenHeight * 0.9;
  }

  void _onBookHoldStart(BookInfo book) {
    final startPos = Offset(book.pos?.x ?? 0, book.pos?.y ?? 0);
    setState(() {
      _heldBook = book;
      _dragPosition = startPos;
      _hasDragged = false;
      _physics = _DragPhysics(startPos);
      _isOverDropZone = false;
    });
    _ticker.start();
  }

  void _onDragUpdate(LongPressMoveUpdateDetails details) {
    if (_heldBook == null || _physics == null) return;
    final Offset origin = Offset(_heldBook!.pos?.x ?? 0, _heldBook!.pos?.y ?? 0);
    final newPos = origin + details.offsetFromOrigin;

    final bool overZone = _isInDropZone(details.globalPosition);

    setState(() {
      _hasDragged = true;
      _dragPosition = newPos;
      _physics!.update(newPos);
      _isOverDropZone = overZone;
    });
  }

  void _onBookHoldEnd(BookInfo book, Offset endPosition, int shelfIndex) {
    _ticker.stop();

    if (_isOverDropZone) {
      setState(() {
        _heldBook = null;
        _physics = null;
        _isOverDropZone = false;
        _hasDragged = false;
      });
      _openDesk(book);
    } else {
      setState(() {
        _heldBook = null;
        _physics = null;
        _isOverDropZone = false;
      });
      if (_hasDragged) {
        final tmp = Utils.updatePos(book, endPosition, shelfIndex);
        book.pos = tmp;
      }
      _hasDragged = false;
    }
  }

  void _openDesk(BookInfo book) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            DeskPage(book: book),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  List<Widget> _buildShelfPlanks(BuildContext context) {
    final double horizontalInset = MediaQuery.sizeOf(context).width * 0.055;
    return _shelfPlanks.map((plank) {
      final (asset, top) = plank;
      return Positioned(
        top: top,
        left: horizontalInset,
        right: horizontalInset,
        height: 40,
        child: Image.asset(
          asset,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      );
    }).toList();
  }

  Widget buildShelf(List<BookInfo> books, int shelfIndex) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        Center(
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.9,
            height: MediaQuery.sizeOf(context).width * 1.5,

            child: Stack(
              children: [

                Positioned.fill(
                  child: Image.asset(
                    'assets/Bookshelf_Shell.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),

                ..._buildShelfPlanks(context),

                ...books.map((book) {
                  final bool isHeld = _heldBook == book;

                  double x, y;
                  double tilt = 0.0;

                  if (isHeld && _physics != null) {
                    x = _physics!.displayPosition.dx;
                    y = _physics!.displayPosition.dy;
                    tilt = _physics!.tiltAngle;
                  } else {
                    x = book.pos?.x ?? Utils.getPos(book.location).$1;
                    y = book.pos?.y ?? Utils.getPos(book.location).$2;
                  }

                  return Positioned(
                    left: x,
                    bottom:  MediaQuery.sizeOf(context).height - y,

                    child: GestureDetector(
                      onLongPressStart: (_) => _onBookHoldStart(book),
                      onLongPressMoveUpdate: isHeld ? _onDragUpdate : null,
                      onLongPressEnd: (_) => _onBookHoldEnd(book, _dragPosition, shelfIndex),
                      onLongPressCancel: () => _onBookHoldEnd(book, _dragPosition, shelfIndex),

                      child: AnimatedScale(
                        scale: isHeld ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        alignment: Alignment.bottomCenter,

                        child: Transform.rotate(
                          angle: tilt,
                          alignment: Alignment.bottomCenter,
                          child: BookWidget(
                            title: book.title,
                            width: book.width * Utils.locationToPixel,
                            height: book.height,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: screenHeight * 0.1,
          child: AnimatedOpacity(
            opacity: _heldBook != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color.fromARGB(255, 112, 64, 10).withOpacity(0.8),
                    const Color.fromARGB(255, 107, 57, 1).withOpacity(0.9),
                  ],
                ),
              ),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    color: _isOverDropZone
                        ? Colors.amber.shade300
                        : Colors.white54,
                    fontSize: 13,
                    fontWeight: _isOverDropZone
                        ? FontWeight.w700
                        : FontWeight.w400,
                    letterSpacing: 1.5,
                  ),
                  child: const Text('DROP ON DESK'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: shelves.length,
        itemBuilder: (context, index) {
          return buildShelf(shelves[index], index);
        },
      ),
    );
  }
}