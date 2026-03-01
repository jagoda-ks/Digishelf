import 'package:flutter/material.dart';
import 'book_utils.dart';
import 'book_widget.dart';
import 'package:flutter/scheduler.dart';

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

class _ShelfPageState extends State<ShelfPage> with SingleTickerProviderStateMixin {
  final List<List<BookInfo>> shelves = _buildShelves();

  BookInfo? _heldBook;
  Offset _dragPosition = Offset.zero;

  _DragPhysics? _physics;
  late final Ticker _ticker;

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

    Utils.books.clear();
    Utils.regionAvailability.clear();
    result.add([
      BookInfo("Book A", "cillian", 20, "2020", "3932850238", null),
      BookInfo("Book B", "cillian", 12, "2021", "1234567890", null),
    ]);

    Utils.books.clear();
    Utils.regionAvailability.clear();
    result.add([
      BookInfo("Book C", "cillian", 18, "2022", "9999999999", null),
      BookInfo("Book D", "cillian", 9,  "2023", "8888888888", null),
    ]);

    return result;
  }

  void _onBookHoldStart(BookInfo book) {
    final startPos = Offset(book.pos?.x ?? 0, book.pos?.y ?? 0);
    setState(() {
      _heldBook = book;
      _dragPosition = startPos;
      _physics = _DragPhysics(startPos);
    });
    _ticker.start();
  }

  void _onDragUpdate(LongPressMoveUpdateDetails details) {
    if (_heldBook == null || _physics == null) return;
    final Offset origin = Offset(_heldBook!.pos?.x ?? 0, _heldBook!.pos?.y ?? 0);
    final newPos = origin + details.offsetFromOrigin;
    setState(() {
      _dragPosition = newPos;
      _physics!.update(newPos);
    });
  }

  void _onBookHoldEnd(BookInfo book, Offset endPosition, int shelfIndex) {
    _ticker.stop();
    setState(() {
      _heldBook = null;
      _physics = null;
    });
    // TODO: snap to nearest available position using endPosition on shelfIndex
  }

  Widget buildShelf(List<BookInfo> books, int shelfIndex) {
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
                top: y,

                child: GestureDetector(
                  onLongPressStart: (_) => _onBookHoldStart(book),
                  onLongPressMoveUpdate: isHeld ? _onDragUpdate : null,
                  onLongPressEnd: (_) => _onBookHoldEnd(book, _dragPosition, shelfIndex),
                  onLongPressCancel: () => _onBookHoldEnd(book, _dragPosition, shelfIndex),

                  child: AnimatedScale(
                    scale: isHeld ? 1.08 : 1.0,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,

                    child: Transform.rotate(
                      angle: tilt,
                      alignment: Alignment.topCenter,
                      child: BookWidget(
                        title: book.title,
                        width: book.width,
                        height: 100,
                      ),
                    ),
                  ),
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
          return buildShelf(shelves[index], index);
        },
      ),
    );
  }
}