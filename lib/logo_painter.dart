import 'package:flutter/material.dart';

class LogoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  LogoPainter({
    this.color = const Color(0xFFFFC107), // Golden yellow
    this.strokeWidth = 3.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double w = size.width;
    final double h = size.height;

    // 1. Draw outer rounded rectangle
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.22, h * 0.15, w * 0.78, h * 0.85),
      const Radius.circular(18),
    );
    canvas.drawRRect(outerRect, paint);

    // 2. Draw inner circle near the top
    final circleCenter = Offset(w * 0.5, h * 0.38);
    final circleRadius = w * 0.14;
    canvas.drawCircle(circleCenter, circleRadius, paint);

    // 3. Draw vertical stem down from the circle
    final stemStart = Offset(w * 0.5, h * 0.38 + circleRadius);
    final stemEnd = Offset(w * 0.5, h * 0.70);
    canvas.drawLine(stemStart, stemEnd, paint);

    // 4. Draw horizontal cross bar
    final crossStart = Offset(w * 0.38, h * 0.60);
    final crossEnd = Offset(w * 0.62, h * 0.60);
    canvas.drawLine(crossStart, crossEnd, paint);

    // 5. Draw the small dot at the bottom
    final paintDot = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.74), 3.0, paintDot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
