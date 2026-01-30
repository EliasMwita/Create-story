import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiEffect extends StatefulWidget {
  const ConfettiEffect({super.key});

  @override
  State<ConfettiEffect> createState() => _ConfettiEffectState();
}

class _ConfettiEffectState extends State<ConfettiEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiPiece> _confetti;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    
    _initializeConfetti();
  }

  void _initializeConfetti() {
    _confetti = List.generate(50, (index) {
      return ConfettiPiece(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 2 - 1,
        size: _random.nextDouble() * 6 + 3,
        speedY: _random.nextDouble() * 2 + 1,
        speedX: _random.nextDouble() * 2 - 1,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: _random.nextDouble() * 0.05 - 0.025,
        color: Color.lerp(
          const Color(0xFFFF9A9E),
          const Color(0xFFA1C4FD),
          _random.nextDouble(),
        )!,
        shape: ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)],
      );
    });
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
        _updateConfetti(_controller.value);
        return CustomPaint(
          painter: ConfettiPainter(confetti: _confetti),
        );
      },
    );
  }

  void _updateConfetti(double delta) {
    for (final piece in _confetti) {
      piece.y += piece.speedY * 0.01;
      piece.x += piece.speedX * 0.01;
      piece.rotation += piece.rotationSpeed;
      
      // Add wind effect
      piece.x += math.sin(delta * 2) * 0.001;
      
      // Reset if off screen
      if (piece.y > 1.5 || piece.x < -0.2 || piece.x > 1.2) {
        piece.y = -0.2;
        piece.x = _random.nextDouble();
        piece.speedY = _random.nextDouble() * 2 + 1;
      }
    }
  }
}

enum ConfettiShape { circle, rectangle, triangle, star }
class ConfettiPiece {
  double x;
  double y;
  double size;
  double speedY;
  double speedX;
  double rotation;
  double rotationSpeed;
  Color color;
  ConfettiShape shape;

  ConfettiPiece({
    required this.x,
    required this.y,
    required this.size,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.shape,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiPiece> confetti;

  ConfettiPainter({required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      final paint = Paint()
        ..color = piece.color
        ..style = PaintingStyle.fill;

      final centerX = piece.x * size.width;
      final centerY = piece.y * size.height;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(piece.rotation);

      _drawShape(canvas, paint, piece.shape, piece.size);

      canvas.restore();
    }
  }

  void _drawShape(Canvas canvas, Paint paint, ConfettiShape shape, double size) {
    switch (shape) {
      case ConfettiShape.circle:
        canvas.drawCircle(Offset.zero, size, paint);
        break;
      case ConfettiShape.rectangle:
        canvas.drawRect(
          Rect.fromCenter(center: Offset.zero, width: size * 2, height: size),
          paint,
        );
        break;
      case ConfettiShape.triangle:
        final path = Path()
          ..moveTo(0, -size)
          ..lineTo(size, size)
          ..lineTo(-size, size)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case ConfettiShape.star:
        _drawStar(canvas, paint, size);
        break;
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = i * (math.pi * 2 / 5);
      final outerX = math.cos(angle) * radius;
      final outerY = math.sin(angle) * radius;
      final innerX = math.cos(angle + math.pi / 5) * radius * 0.5;
      final innerY = math.sin(angle + math.pi / 5) * radius * 0.5;
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
