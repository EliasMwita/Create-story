import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';

class AestheticTemplate extends StatelessWidget {
  const AestheticTemplate({super.key});

  static const config = TemplateModel(
    id: 'aesthetic',
    name: 'Dreamy Glow',
    tag: 'SOFT',
    colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
    icon: Icons.auto_awesome_outlined,
    textColor: Colors.black87,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.0)
          ],
        ),
      ),
    );
  }
}
