import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/widgets/templates/components/particle_background.dart';

class BeatTemplate extends StatelessWidget {
  const BeatTemplate({super.key});

  static const config = TemplateModel(
    id: 'beat',
    name: 'Fast Beat',
    tag: 'TRENDY',
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    icon: Icons.bolt,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: AnimatedParticleBackground(color: Colors.white),
    );
  }
}
