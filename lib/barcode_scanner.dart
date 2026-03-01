import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Opens the camera and scans for a barcode.
/// Returns the ISBN string if found, or null if the user pressed back.
///
/// Usage:
///   final isbn = await Navigator.of(context).push<String?>(
///     MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
///   );
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
    final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8],
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue;
    if (code == null || code.isEmpty) return;

    // Only accept ISBN-13 (starts with 978 or 979) or ISBN-10 lengths
    final isIsbn = (code.length == 13 &&
            (code.startsWith('978') || code.startsWith('979'))) ||
        code.length == 10;

    if (!isIsbn) return;

    setState(() => _hasScanned = true);
    _controller.stop();

    // Pop and return the ISBN to the caller
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera feed ──────────────────────────────────────────────
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // ── Dark vignette overlay with cutout ────────────────────────
          _ScanOverlay(),

          // ── Top bar: back button + title ─────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // Back button
                  Material(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(24),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => Navigator.of(context).pop(null),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Scan ISBN barcode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom hint label ─────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * 0.18,
            child: const Column(
              children: [
                Text(
                  'Align the barcode inside the box',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.4,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ISBN-10 or ISBN-13 barcodes only',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Overlay painter ────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Cutout window — wide and short for a barcode
    final cutoutWidth = size.width * 0.78;
    final cutoutHeight = cutoutWidth * 0.38;
    final cutoutLeft = (size.width - cutoutWidth) / 2;
    final cutoutTop = (size.height - cutoutHeight) / 2 - size.height * 0.04;

    return CustomPaint(
      size: Size(size.width, size.height),
      painter: _OverlayPainter(
        cutout: Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutWidth, cutoutHeight),
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final Rect cutout;
  const _OverlayPainter({required this.cutout});

  @override
  void paint(Canvas canvas, Size size) {
    final dimPaint = Paint()..color = Colors.black.withOpacity(0.62);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw dimmed background with a transparent hole for the scan window
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(fullRect),
        Path()..addRRect(RRect.fromRectAndRadius(cutout, const Radius.circular(8))),
      ),
      dimPaint,
    );

    // White border around the cutout
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutout, const Radius.circular(8)),
      borderPaint,
    );

    // Corner accent marks
    _drawCorners(canvas, cutout);
  }

  void _drawCorners(Canvas canvas, Rect r) {
    const double len = 22;
    const double thickness = 4;
    final paint = Paint()
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(Offset(r.left, r.top + len), Offset(r.left, r.top), paint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + len, r.top), paint);
    // Top-right
    canvas.drawLine(Offset(r.right - len, r.top), Offset(r.right, r.top), paint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(r.left, r.bottom - len), Offset(r.left, r.bottom), paint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + len, r.bottom), paint);
    // Bottom-right
    canvas.drawLine(Offset(r.right - len, r.bottom), Offset(r.right, r.bottom), paint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - len), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}