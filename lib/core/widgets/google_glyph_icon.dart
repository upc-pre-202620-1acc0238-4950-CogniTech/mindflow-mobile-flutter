import 'package:flutter/material.dart';

/// Placeholder Google glyph from the design handoff (a circle with a
/// radius stroke) — not the real Google "G" mark, matched 1:1 to the
/// `.dc.html` source so the mock-up and the app read the same.
class GoogleGlyphIcon extends StatelessWidget {
  final Color color;
  const GoogleGlyphIcon({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(20, 20), painter: _GoogleGlyphPainter(color));
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  final Color color;
  _GoogleGlyphPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 8 / 24, paint);
    canvas.drawLine(center, Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(covariant _GoogleGlyphPainter oldDelegate) => oldDelegate.color != color;
}
