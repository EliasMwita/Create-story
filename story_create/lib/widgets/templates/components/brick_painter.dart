import 'package:flutter/material.dart';

class BrickPainter extends CustomPainter {
  final double brickHeight;
  final double brickWidth;

  BrickPainter({this.brickHeight = 20.0, this.brickWidth = 40.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += brickHeight) {
      final isOffset = (y / brickHeight).floor() % 2 != 0;
      
      // Horizontal lines
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      
      // Vertical lines
      for (double x = isOffset ? -brickWidth / 2 : 0; x < size.width; x += brickWidth) {
        canvas.drawLine(
          Offset(x, y), 
          Offset(x, y + brickHeight), 
          paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
