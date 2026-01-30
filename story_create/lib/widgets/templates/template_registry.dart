import 'package:flutter/material.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/widgets/templates/beat_template.dart';
import 'package:story_create/widgets/templates/confetti_template.dart';
import 'package:story_create/widgets/templates/minimal_template.dart';
import 'package:story_create/widgets/templates/film_template.dart';
import 'package:story_create/widgets/templates/retro_template.dart';
import 'package:story_create/widgets/templates/aesthetic_template.dart';
import 'package:story_create/widgets/templates/none_template.dart';

class TemplateRegistry {
  static final List<TemplateModel> allTemplates = [
    MinimalTemplate.config,
    FlowerFallTemplate.config,
    ConfettiTemplate.config,
    FilmTemplate.config,
    RetroTemplate.config,
    AestheticTemplate.config,
    NoneTemplate.config,
  ];

  static Widget getOverlay(String id, {double borderRadius = 24}) {
    switch (id) {
      case 'flower_fall':
        return const FlowerFallTemplate();
      case 'confetti':
        return const ConfettiTemplate();
      case 'minimal':
        return MinimalTemplate(borderRadius: borderRadius);
      case 'film':
        return const FilmTemplate();
      case 'retro':
      case 'retro_vhs':
        return const RetroTemplate();
      case 'aesthetic':
        return const AestheticTemplate();
      case 'none':
        return const NoneTemplate();
      default:
        return const SizedBox.shrink();
    }
  }

  static TemplateModel getTemplate(String id) {
    return allTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => MinimalTemplate.config,
    );
  }
}
