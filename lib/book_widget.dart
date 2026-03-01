import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookWidget extends StatefulWidget {
  final String title;
  final double width;
  final double height;
  final String isbn;
  final VoidCallback? onTap;

  const BookWidget({
    super.key,
    required this.title,
    required this.width,
    required this.height,
    required this.isbn,
    this.onTap,
  });

  @override
  State<BookWidget> createState() => _BookWidgetState();
}

class _BookWidgetState extends State<BookWidget> {
  bool _isHovered = false;
  Uint8List? _coverBytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCover();
  }

  @override
  void didUpdateWidget(BookWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isbn != widget.isbn) {
      setState(() {
        _coverBytes = null;
        _loading = true;
      });
      _fetchCover();
    }
  }

  Future<void> _fetchCover() async {
    try {
      // Open Library cover API — same source used by Utils.fetchBook
      final url = 'https://covers.openlibrary.org/b/isbn/${widget.isbn}-M.jpg?default=false';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _coverBytes = response.bodyBytes;
          _loading = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = false),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_isHovered ? 1 : 0),
          child: Stack(
            children: [
              Positioned(
                left: widget.width * 0.08,
                top: 0,
                bottom: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                  child: _loading
                      ? _placeholder()
                      : _coverBytes != null
                          ? Image.memory(
                              _coverBytes!,
                              filterQuality: FilterQuality.medium,
                            )
                          : _fallback(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade700,
            Colors.grey.shade500,
          ],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: widget.width,
          height: widget.width,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.grey.shade300,
          ),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.shade700,
            Colors.amber.shade900,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: (widget.width * 0.12).clamp(6.0, 13.0),
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}