import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/widgets/templates/components/particle_background.dart';

class RetroTemplate extends StatelessWidget {
  const RetroTemplate({super.key});

  static const config = TemplateModel(
    id: 'retro',
    name: 'Retro VHS',
    tag: '90s VIBE',
    colors: [Color(0xFFFF0099), Color(0xFF493240)],
    icon: Icons.videocam_outlined,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.cyan.withValues(alpha: 0.1),
                Colors.pinkAccent.withValues(alpha: 0.1)
              ],
            ),
          ),
        ),
        const Positioned.fill(
          child: AnimatedParticleBackground(color: Colors.pinkAccent),
        ),
      ],
    );
  }
}
