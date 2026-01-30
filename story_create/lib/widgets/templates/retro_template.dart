import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';

class RetroTemplate extends StatelessWidget {
  const RetroTemplate({super.key});

  static const config = TemplateModel(
    id: 'retro_vhs',
    name: 'Retro VHS',
    tag: '90s VIBE',
    colors: [
      Color(0xFFFF0099),
      Color(0xFF00FFCC),
      Color(0xFFFFCC00),
      Color(0xFF493240)
    ],
    icon: Icons.videocam_outlined,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main VHS Gradient (Semi-transparent overlay)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF0F0C29).withValues(alpha: 0.2),
                  const Color(0xFF302B63).withValues(alpha: 0.2),
                  const Color(0xFF24243E).withValues(alpha: 0.2),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),

        // Scan Lines Effect
        const Positioned.fill(
          child: ScanLinesOverlay(),
        ),

        // VHS Static Noise
        const Positioned.fill(
          child: VHSStaticNoise(),
        ),

        // Retro Grid
        const Positioned.fill(
          child: RetroGrid(),
        ),

        // Flying VHS Tapes Animation
        const Positioned.fill(
          child: FlyingVHSAnimation(),
        ),

        // Glitch Effect
        const Positioned.fill(
          child: VHSGlitchEffect(),
        ),

        // Edge Vignette
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.8,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
                stops: const [0.5, 1.0],
              ),
            ),
          ),
        ),

        // Color Bleed Effect (Right Side)
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [
                  const Color(0xFFFF0099).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Color Bleed Effect (Left Side)
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  const Color(0xFF00FFCC).withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== VHS Static Noise ====================
class VHSStaticNoise extends StatefulWidget {
  const VHSStaticNoise({super.key});

  @override
  State<VHSStaticNoise> createState() => _VHSStaticNoiseState();
}

class _VHSStaticNoiseState extends State<VHSStaticNoise>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
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
          painter: StaticNoisePainter(seed: _controller.value * 1000),
        );
      },
    );
  }
}

class StaticNoisePainter extends CustomPainter {
  final double seed;

  StaticNoisePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed.toInt());
    final paint = Paint();

    // Draw static noise particles
    for (int i = 0; i < 300; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final alpha = random.nextDouble() * 0.3;
      final sizeDot = random.nextDouble() * 2 + 0.5;

      paint.color = random.nextBool()
          ? const Color(0xFFFF0099).withValues(alpha: alpha)
          : const Color(0xFF00FFCC).withValues(alpha: alpha);

      canvas.drawCircle(Offset(x, y), sizeDot, paint);
    }

    // Draw horizontal static lines
    for (int i = 0; i < 20; i++) {
      final y = random.nextDouble() * size.height;
      final height = random.nextDouble() * 3 + 1;
      final alpha = random.nextDouble() * 0.2 + 0.1;

      paint.color = Colors.white.withValues(alpha: alpha);

      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StaticNoisePainter oldDelegate) => true;
}

// ==================== Scan Lines Overlay ====================
class ScanLinesOverlay extends StatelessWidget {
  const ScanLinesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ScanLinesPainter(),
    );
  }
}

class ScanLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    const lineHeight = 2.0;
    const spacing = 4.0;

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, lineHeight),
        paint,
      );
    }

    // Draw CRT curvature effect
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// ==================== Retro Grid ====================
class RetroGrid extends StatefulWidget {
  const RetroGrid({super.key});

  @override
  State<RetroGrid> createState() => _RetroGridState();
}

class _RetroGridState extends State<RetroGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
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
          painter: RetroGridPainter(animationValue: _controller.value),
        );
      },
    );
  }
}

class RetroGridPainter extends CustomPainter {
  final double animationValue;

  RetroGridPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF00FFCC).withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const gridSize = 40.0;

    // Vertical lines with subtle animation
    for (double x = 0; x < size.width; x += gridSize) {
      final offset = math.sin(x * 0.01 + animationValue * math.pi * 2) * 2;
      canvas.drawLine(
        Offset(x + offset, 0),
        Offset(x + offset, size.height),
        gridPaint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      final offset = math.cos(y * 0.01 + animationValue * math.pi * 2) * 2;
      canvas.drawLine(
        Offset(0, y + offset),
        Offset(size.width, y + offset),
        gridPaint,
      );
    }

    // Draw grid intersections
    final pointPaint = Paint()
      ..color = const Color(0xFFFF0099).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (double x = gridSize / 2; x < size.width; x += gridSize) {
      for (double y = gridSize / 2; y < size.height; y += gridSize) {
        final pulse = 0.5 + 0.5 * math.sin(animationValue * math.pi * 2 + x * y * 0.0001);
        final radius = 1.0 + pulse * 2;
        
        canvas.drawCircle(
          Offset(x, y),
          radius,
          pointPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(RetroGridPainter oldDelegate) => true;
}

// ==================== Flying VHS Animation ====================
class FlyingVHSAnimation extends StatefulWidget {
  const FlyingVHSAnimation({super.key});

  @override
  State<FlyingVHSAnimation> createState() => _FlyingVHSAnimationState();
}

class _FlyingVHSAnimationState extends State<FlyingVHSAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<VHSTape> _tapes;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _initializeTapes();
  }

  void _initializeTapes() {
    _tapes = List.generate(8, (index) {
      final tapeColors = [
        const Color(0xFFFF0099),
        const Color(0xFF00FFCC),
        const Color(0xFFFFCC00),
        const Color(0xFF9933FF),
      ];

      return VHSTape(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 2 - 1,
        size: _random.nextDouble() * 40 + 20,
        speed: _random.nextDouble() * 0.5 + 0.2,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: _random.nextDouble() * 0.01 - 0.005,
        color: tapeColors[_random.nextInt(tapeColors.length)],
        tapeType: VHSTapeType.values[_random.nextInt(VHSTapeType.values.length)],
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
        _updateTapes(_controller.value);
        return CustomPaint(
          painter: VHSTapePainter(tapes: _tapes),
        );
      },
    );
  }

  void _updateTapes(double delta) {
    for (final tape in _tapes) {
      tape.y += tape.speed * 0.01;
      tape.rotation += tape.rotationSpeed;
      tape.x += math.sin(delta * 2 + tape.y) * 0.002;

      if (tape.y > 1.5) {
        tape.y = -0.5;
        tape.x = _random.nextDouble();
      }
    }
  }
}

enum VHSTapeType { vhs, cassette, filmReel }

class VHSTape {
  double x;
  double y;
  double size;
  double speed;
  double rotation;
  double rotationSpeed;
  Color color;
  VHSTapeType tapeType;

  VHSTape({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.tapeType,
  });
}

class VHSTapePainter extends CustomPainter {
  final List<VHSTape> tapes;

  VHSTapePainter({required this.tapes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final tape in tapes) {
      final paint = Paint()
        ..color = tape.color.withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;

      final centerX = tape.x * size.width;
      final centerY = tape.y * size.height;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(tape.rotation);

      _drawVHSTape(canvas, paint, tape.tapeType, tape.size);

      canvas.restore();

      // Draw trail effect
      final trailPaint = Paint()
        ..color = tape.color.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(
          Offset(centerX, centerY - i * tape.size * 0.5),
          tape.size * 0.3,
          trailPaint,
        );
      }
    }
  }

  void _drawVHSTape(Canvas canvas, Paint paint, VHSTapeType type, double size) {
    switch (type) {
      case VHSTapeType.vhs:
        _drawVHSCassette(canvas, paint, size);
        break;
      case VHSTapeType.cassette:
        _drawCassette(canvas, paint, size);
        break;
      case VHSTapeType.filmReel:
        _drawFilmReel(canvas, paint, size);
        break;
    }
  }

  void _drawVHSCassette(Canvas canvas, Paint paint, double size) {
    // Draw VHS tape body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size, height: size * 0.6),
        Radius.circular(size * 0.1),
      ),
      paint,
    );

    // Draw tape window
    final windowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size * 0.6,
        height: size * 0.3,
      ),
      windowPaint,
    );

    // Draw label
    final labelPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(0, -size * 0.15),
        width: size * 0.4,
        height: size * 0.1,
      ),
      labelPaint,
    );
  }

  void _drawCassette(Canvas canvas, Paint paint, double size) {
    // Draw cassette body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: size * 0.8, height: size),
        Radius.circular(size * 0.1),
      ),
      paint,
    );

    // Draw tape holes
    final holePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(-size * 0.2, 0), size * 0.15, holePaint);
    canvas.drawCircle(Offset(size * 0.2, 0), size * 0.15, holePaint);
  }

  void _drawFilmReel(Canvas canvas, Paint paint, double size) {
    // Draw reel center
    canvas.drawCircle(Offset.zero, size * 0.3, paint);

    // Draw reel arms
    for (int i = 0; i < 4; i++) {
      final angle = i * (math.pi / 2);
      final x = math.cos(angle) * size * 0.5;
      final y = math.sin(angle) * size * 0.5;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: size * 0.1,
          height: size * 0.6,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(VHSTapePainter oldDelegate) => true;
}

// ==================== VHS Glitch Effect ====================
class VHSGlitchEffect extends StatefulWidget {
  const VHSGlitchEffect({super.key});

  @override
  State<VHSGlitchEffect> createState() => _VHSGlitchEffectState();
}

class _VHSGlitchEffectState extends State<VHSGlitchEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
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
          painter: GlitchPainter(
            animationValue: _controller.value,
            glitchIntensity: _controller.value > 0.8 ? 1.0 : 0.0,
          ),
        );
      },
    );
  }
}

class GlitchPainter extends CustomPainter {
  final double animationValue;
  final double glitchIntensity;

  GlitchPainter({
    required this.animationValue,
    required this.glitchIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (glitchIntensity > 0) {
      final random = math.Random(animationValue.toInt());
      
      // Draw horizontal glitch lines
      for (int i = 0; i < 5; i++) {
        final y = random.nextDouble() * size.height;
        final height = random.nextDouble() * 10 + 5;
        final offset = random.nextDouble() * 20 - 10;
        
        final glitchPaint = Paint()
          ..color = i.isEven 
              ? const Color(0xFFFF0099).withValues(alpha: 0.3)
              : const Color(0xFF00FFCC).withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;
        
        canvas.drawRect(
          Rect.fromLTWH(offset, y, size.width, height),
          glitchPaint,
        );
      }

      // Draw vertical glitch slices
      for (int i = 0; i < 3; i++) {
        final x = random.nextDouble() * size.width;
        final width = random.nextDouble() * 15 + 5;
        final offset = random.nextDouble() * 30 - 15;
        
        final slicePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        
        canvas.drawRect(
          Rect.fromLTWH(x, offset, width, size.height),
          slicePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GlitchPainter oldDelegate) => true;
}