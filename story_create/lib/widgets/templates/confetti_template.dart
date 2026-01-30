import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/widgets/templates/components/confetti_effect.dart';

class ConfettiTemplate extends StatelessWidget {
  const ConfettiTemplate({super.key});

  static const config = TemplateModel(
    id: 'confetti',
    name: 'Party Confetti',
    tag: 'CELEBRATION',
    colors: [Color(0xFFFF9A9E), Color(0xFFA1C4FD)],
    icon: Icons.celebration,
    textColor: Colors.white,
  );

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned.fill(
          child: ConfettiEffect(),
        ),
      ],
    );
  }
}
