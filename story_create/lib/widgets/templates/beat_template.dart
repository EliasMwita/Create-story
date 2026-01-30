import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/widgets/templates/components/particle_background.dart';

class FlowerFallTemplate extends StatelessWidget {
  const FlowerFallTemplate({super.key});

  static const config = TemplateModel(
    id: 'flower_fall',
    name: 'Flower Fall',
    tag: 'ELEGANT',
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFA1C4FD)],
    icon: Icons.emoji_nature,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient Background (Semi-transparent overlay)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF667EEA).withValues(alpha: 0.2),
                  const Color(0xFF764BA2).withValues(alpha: 0.2),
                  const Color(0xFFF093FB).withValues(alpha: 0.2),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),
        
        // Animated Particles (Flowers)
        const Positioned.fill(
          child: FlowerFallAnimation(),
        ),
        
        // Glowing Center Effect
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        
        // Subtle Pattern Overlay
        Positioned.fill(
          child: CustomPaint(
            painter: _PatternPainter(),
          ),
        ),
      ],
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = 40.0;
    final random = math.Random(42);
    
    // Draw subtle grid pattern
    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        if (random.nextDouble() < 0.3) {
          final radius = random.nextDouble() * 3 + 1;
          final circlePaint = Paint()
            ..color = Colors.white.withOpacity(0.1)
            ..style = PaintingStyle.fill;
          
          canvas.drawCircle(
            Offset(x + random.nextDouble() * gridSize, 
                   y + random.nextDouble() * gridSize),
            radius,
            circlePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}