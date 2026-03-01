import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

class PixelateFilter extends StatefulWidget {
  final Widget child;
  final double pixelSize;

  const PixelateFilter({
    super.key,
    required this.child,
    this.pixelSize = 6.0,
  });

  @override
  State<PixelateFilter> createState() => _PixelateFilterState();
}

class _PixelateFilterState extends State<PixelateFilter> {
  final GlobalKey _repaintKey = GlobalKey();
  ui.Image? _pixelatedImage;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_scheduleCapture);
  }

  void _scheduleCapture(Duration _) {
    _capture();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback(_scheduleCapture);
    }
  }

  Future<void> _capture() async {
    if (_capturing) return;
    _capturing = true;

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final pixelRatio = 1.0 / widget.pixelSize;
      final image = await boundary.toImage(pixelRatio: pixelRatio);

      if (mounted) {
        setState(() {
          _pixelatedImage?.dispose();
          _pixelatedImage = image;
        });
      }
    } finally {
      _capturing = false;
    }
  }

  @override
  void dispose() {
    _pixelatedImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Real interactive widget — on screen, receives touches
        RepaintBoundary(
          key: _repaintKey,
          child: widget.child,
        ),

        // Pixelated overlay — visual only, ignores all touches
        if (_pixelatedImage != null)
          Positioned.fill(
            child: IgnorePointer(
              child: RawImage(
                image: _pixelatedImage,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
      ],
    );
  }
}