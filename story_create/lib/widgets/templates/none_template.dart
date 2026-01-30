import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';

class NoneTemplate extends StatelessWidget {
  const NoneTemplate({super.key});

  static const config = TemplateModel(
    id: 'none',
    name: 'Blank Canvas',
    tag: 'CUSTOM',
    colors: [Colors.white, Colors.white],
    icon: Icons.add_rounded,
    textColor: Colors.black54,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: 0.1,
        child: Icon(
          Icons.grid_4x4_rounded,
          size: 80,
          color: config.textColor,
        ),
      ),
    );
  }
}
