import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlowerFallAnimation extends StatefulWidget {
  const FlowerFallAnimation({super.key});

  @override
  State<FlowerFallAnimation> createState() => _FlowerFallAnimationState();
}

class _FlowerFallAnimationState extends State<FlowerFallAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<FlowerParticle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    _initializeParticles();
  }

  void _initializeParticles() {
    _particles = List.generate(30, (index) {
      final flowerTypes = [FlowerType.rose, FlowerType.sakura, FlowerType.petal];
      final flowerType = flowerTypes[_random.nextInt(flowerTypes.length)];
      
      return FlowerParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 2 - 1, // Start above screen
        size: _random.nextDouble() * 0.1 + 0.05,
        speed: _random.nextDouble() * 0.5 + 0.3,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: _random.nextDouble() * 0.02 - 0.01,
        opacity: _random.nextDouble() * 0.5 + 0.5,
        type: flowerType,
        colorVariation: _random.nextDouble(),
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
        _updateParticles(_controller.value);
        return CustomPaint(
          painter: FlowerPainter(particles: _particles),
        );
      },
    );
  }

  void _updateParticles(double delta) {
    for (final particle in _particles) {
      particle.y += particle.speed * 0.01;
      particle.rotation += particle.rotationSpeed;
      
      // Reset particle if it goes off screen
      if (particle.y > 1.5) {
        particle.y = -0.2;
        particle.x = _random.nextDouble();
      }
      
      // Subtle horizontal movement
      particle.x += math.sin(delta * math.pi * 2 + particle.x * math.pi) * 0.001;
    }
  }
}

enum FlowerType { rose, sakura, petal }

class FlowerParticle {
  double x;
  double y;
  double size;
  double speed;
  double rotation;
  double rotationSpeed;
  double opacity;
  FlowerType type;
  double colorVariation;

  FlowerParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.type,
    required this.colorVariation,
  });
}

class FlowerPainter extends CustomPainter {
  final List<FlowerParticle> particles;

  FlowerPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = _getFlowerColor(particle.type, particle.colorVariation)
            .withValues(alpha: particle.opacity * 0.8)
        ..style = PaintingStyle.fill;

      final centerX = particle.x * size.width;
      final centerY = particle.y * size.height;
      final radius = particle.size * size.width;

      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(particle.rotation);

      _drawFlower(canvas, paint, particle.type, radius);

      canvas.restore();
      
      // Draw glow effect
      final glowPaint = Paint()
        ..color = _getFlowerColor(particle.type, particle.colorVariation)
            .withValues(alpha: particle.opacity * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius * 1.5,
        glowPaint,
      );
    }
  }

  Color _getFlowerColor(FlowerType type, double variation) {
    switch (type) {
      case FlowerType.rose:
        return Color.lerp(
          const Color(0xFFFF9A9E),
          const Color(0xFFFF6B6B),
          variation,
        )!;
      case FlowerType.sakura:
        return Color.lerp(
          const Color(0xFFFAD0C4),
          const Color(0xFFFFD1FF),
          variation,
        )!;
      case FlowerType.petal:
        return Color.lerp(
          const Color(0xFFA1C4FD),
          const Color(0xFFC2E9FB),
          variation,
        )!;
    }
  }

  void _drawFlower(Canvas canvas, Paint paint, FlowerType type, double radius) {
    switch (type) {
      case FlowerType.rose:
        _drawRose(canvas, paint, radius);
        break;
      case FlowerType.sakura:
        _drawSakura(canvas, paint, radius);
        break;
      case FlowerType.petal:
        _drawPetal(canvas, paint, radius);
        break;
    }
  }

  void _drawRose(Canvas canvas, Paint paint, double radius) {
    // Draw rose with multiple layers
    for (int i = 0; i < 3; i++) {
      final layerRadius = radius * (0.8 - i * 0.2);
      canvas.drawCircle(Offset.zero, layerRadius, paint);
      
      // Draw petals
      for (int j = 0; j < 5; j++) {
        final angle = j * (math.pi * 2 / 5);
        final petalX = math.cos(angle) * layerRadius;
        final petalY = math.sin(angle) * layerRadius;
        
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(petalX, petalY),
            width: radius * 0.6,
            height: radius * 0.8,
          ),
          paint,
        );
      }
    }
  }

  void _drawSakura(Canvas canvas, Paint paint, double radius) {
    // Draw sakura flower (5 petals)
    for (int i = 0; i < 5; i++) {
      final angle = i * (math.pi * 2 / 5);
      final petalPath = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(
          radius * 0.5,
          radius * 0.2,
          radius * math.cos(angle),
          radius * math.sin(angle),
        )
        ..quadraticBezierTo(
          radius * 0.2,
          radius * 0.5,
          0,
          0,
        );
      
      canvas.drawPath(petalPath, paint);
    }
    
    // Center circle
    canvas.drawCircle(Offset.zero, radius * 0.3, paint);
  }

  void _drawPetal(Canvas canvas, Paint paint, double radius) {
    // Simple petal shape
    final petalPath = Path()
      ..moveTo(0, -radius)
      ..quadraticBezierTo(radius * 0.8, 0, 0, radius)
      ..quadraticBezierTo(-radius * 0.8, 0, 0, -radius);
    
    canvas.drawPath(petalPath, paint);
    
    // Veins on petal
    final veinPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    
    canvas.drawLine(Offset(0, -radius * 0.8), Offset(0, radius * 0.8), veinPaint);
  }

  @override
  bool shouldRepaint(FlowerPainter oldDelegate) => true;
}

class AnimatedParticleBackground extends StatefulWidget {
  final Color color;
  const AnimatedParticleBackground({super.key, required this.color});

  @override
  State<AnimatedParticleBackground> createState() => _AnimatedParticleBackgroundState();
}

class _AnimatedParticleBackgroundState extends State<AnimatedParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _particles = List.generate(20, (index) => _Particle(_random));
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
        for (final particle in _particles) {
          particle.update();
        }
        return CustomPaint(
          painter: _ParticlePainter(_particles, widget.color),
        );
      },
    );
  }
}

class _Particle {
  double x, y, vx, vy, size;
  final math.Random random;

  _Particle(this.random)
      : x = random.nextDouble(),
        y = random.nextDouble(),
        vx = (random.nextDouble() - 0.5) * 0.002,
        vy = (random.nextDouble() - 0.5) * 0.002,
        size = random.nextDouble() * 4 + 2;

  void update() {
    x += vx;
    y += vy;
    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color color;

  _ParticlePainter(this.particles, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.3);
    for (final p in particles) {
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
