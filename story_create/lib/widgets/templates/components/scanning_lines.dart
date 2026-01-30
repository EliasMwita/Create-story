import 'package:flutter/material.dart';

class AnimatedScanningLines extends StatefulWidget {
  const AnimatedScanningLines({super.key});

  @override
  State<AnimatedScanningLines> createState() => _AnimatedScanningLinesState();
}

class _AnimatedScanningLinesState extends State<AnimatedScanningLines>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ScanningLinesPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

class ScanningLinesPainter extends CustomPainter {
  final double animationValue;

  ScanningLinesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;

    // Moving horizontal line
    final y = animationValue * size.height;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint..strokeWidth = 2.0);

    // Static scanlines
    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint..strokeWidth = 0.5);
    }
  }

  @override
  bool shouldRepaint(ScanningLinesPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}
