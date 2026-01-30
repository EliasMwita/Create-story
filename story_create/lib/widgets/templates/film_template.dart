import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';

class FilmTemplate extends StatelessWidget {
  const FilmTemplate({super.key});

  static const config = TemplateModel(
    id: 'film',
    name: 'Cinematic Pro',
    tag: '4K LOG',
    colors: [Colors.black, Colors.black],
    icon: Icons.movie_filter_rounded,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          /// 🎨 Color Grading + Vignette
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.4,
                colors: [
                  const Color(0xFF1C2A33).withValues(alpha: 0.3), // Teal cold tone
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),

          /// 📺 Scanlines
          const Positioned.fill(child: _Scanlines()),

          /// 🎞 Film Strip Edges
          _buildFilmEdges(),

          /// 📐 Viewfinder Corners
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: ViewfinderCorners(),
            ),
          ),

          /// 🎯 Focus Bracket
          const Center(child: _FocusBracket()),

          /// 🔴 Header HUD
          Positioned(
            top: 36,
            left: 24,
            right: 24,
            child: _GlassPanel(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    CinematicHeader(),
                    SizedBox(width: 24),
                    _AudioMeter(),
                    SizedBox(width: 24),
                    BatteryIndicator(),
                  ],
                ),
              ),
            ),
          ),

          /// ⏱ Footer HUD
          Positioned(
            bottom: 36,
            left: 24,
            right: 24,
            child: _GlassPanel(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    CameraMetadata(),
                    SizedBox(width: 48),
                    TimeCodeWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilmEdges() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        2,
        (_) => Container(
          height: 36,
          color: Colors.black.withValues(alpha: 0.9),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final count = (constraints.maxWidth / 22).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  count,
                  (_) => Container(
                    width: 14,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141414),
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.white10, width: 0.5),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white10),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Scanlines extends StatelessWidget {
  const _Scanlines();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScanlinePainter());
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FocusBracket extends StatelessWidget {
  const _FocusBracket();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Icon(Icons.add, color: Colors.white24, size: 28),
      ),
    );
  }
}

class ViewfinderCorners extends StatelessWidget {
  const ViewfinderCorners({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: CornerPainter());
  }
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const length = 24.0;

    void drawCorner(Offset start, Offset corner, Offset end) {
      canvas.drawPath(
          Path()
            ..moveTo(start.dx, start.dy)
            ..lineTo(corner.dx, corner.dy)
            ..lineTo(end.dx, end.dy),
          paint);
    }

    drawCorner(const Offset(0, length), Offset.zero, const Offset(length, 0));
    drawCorner(Offset(size.width - length, 0), Offset(size.width, 0),
        Offset(size.width, length));
    drawCorner(Offset(0, size.height - length), Offset(0, size.height),
        Offset(length, size.height));
    drawCorner(Offset(size.width - length, size.height),
        Offset(size.width, size.height),
        Offset(size.width, size.height - length));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CinematicHeader extends StatefulWidget {
  const CinematicHeader({super.key});

  @override
  State<CinematicHeader> createState() => _CinematicHeaderState();
}

class _CinematicHeaderState extends State<CinematicHeader> {
  bool _visible = true;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (mounted) setState(() => _visible = !_visible);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: _visible ? 1.0 : 0.2,
          child:
              const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
        ),
        const SizedBox(width: 8),
        const Text(
          'REC',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _AudioMeter extends StatelessWidget {
  const _AudioMeter();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(12, (index) {
        final color = index > 9
            ? Colors.red
            : (index > 7 ? Colors.yellow : Colors.green);
        return Container(
          width: 3,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: index % 3 == 0 ? 0.8 : 0.3),
            borderRadius: BorderRadius.circular(0.5),
          ),
        );
      }),
    );
  }
}

class BatteryIndicator extends StatelessWidget {
  const BatteryIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'STBY',
          style: TextStyle(
            color: Colors.greenAccent.withValues(alpha: 0.8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.battery_charging_full_rounded,
            color: Colors.white70, size: 16),
      ],
    );
  }
}

class CameraMetadata extends StatelessWidget {
  const CameraMetadata({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildMetaRow('FPS', '60.00'),
        _buildMetaRow('SHUTTER', '1/125'),
        _buildMetaRow('ISO', '800'),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          color: Colors.white10,
          child: const Text(
            'RAW 10-BIT',
            style: TextStyle(
                color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label ',
              style: const TextStyle(color: Colors.white38, fontSize: 9)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class TimeCodeWidget extends StatelessWidget {
  const TimeCodeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'TC 00:12:44:02',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Courier',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'A:012 C:004',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
