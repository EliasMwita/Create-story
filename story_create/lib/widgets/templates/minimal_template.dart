import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/widgets/templates/components/brick_painter.dart';

class MinimalTemplate extends StatelessWidget {
  final double borderRadius;
  const MinimalTemplate({super.key, this.borderRadius = 24});

  static const config = TemplateModel(
    id: 'minimal',
    name: 'Brick Light',
    tag: 'MINIMAL',
    colors: [Colors.black, Colors.black],
    icon: Icons.lightbulb_outline_rounded,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. The Brick Wall Background (Procedural)
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              color: Colors.transparent,
              child: CustomPaint(
                painter: BrickPainter(),
              ),
            ),
          ),
        ),
        // 2. The Glowing Light Effect
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: RadialGradient(
              center: const Alignment(0, -0.4),
              radius: 0.8,
              colors: [
                Colors.orangeAccent.withValues(alpha: 0.4),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        // 3. Top shadow
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
