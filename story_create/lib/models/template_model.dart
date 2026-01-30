import 'package:flutter/material.dart';

class TemplateModel {
  final String id;
  final String name;
  final String tag;
  final List<Color> colors;
  final IconData icon;
  final Color textColor;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.colors,
    required this.icon,
    required this.textColor,
  });
}
