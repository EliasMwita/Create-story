import 'package:flutter/material.dart';
import 'package:story_create/utils/colors.dart';

class Mood {
  final String name;
  final String emoji;
  final String color;
  final String musicGenre;
  
  const Mood({
    required this.name,
    required this.emoji,
    required this.color,
    required this.musicGenre,
  });

  Color get actualColor {
    switch (color) {
      case 'moodHappy':
        return AppColors.moodHappy;
      case 'moodSad':
        return AppColors.moodSad;
      case 'moodRomantic':
        return AppColors.moodRomantic;
      case 'moodMotivational':
        return AppColors.moodMotivational;
      case 'moodCalm':
        return AppColors.moodCalm;
      case 'moodAdventure':
        return AppColors.moodAdventure;
      default:
        return AppColors.primary;
    }
  }

  static Mood fromName(String name) {
    return moods.firstWhere(
      (m) => m.name == name,
      orElse: () => moods.first,
    );
  }
  
  static final List<Mood> moods = [
    Mood(
      name: 'Happy',
      emoji: '😊',
      color: 'moodHappy',
      musicGenre: 'Upbeat',
    ),
    Mood(
      name: 'Sad',
      emoji: '😔',
      color: 'moodSad',
      musicGenre: 'Melancholic',
    ),
    Mood(
      name: 'Romantic',
      emoji: '❤️',
      color: 'moodRomantic',
      musicGenre: 'Romantic',
    ),
    Mood(
      name: 'Motivational',
      emoji: '💪',
      color: 'moodMotivational',
      musicGenre: 'Inspirational',
    ),
    Mood(
      name: 'Calm',
      emoji: '😌',
      color: 'moodCalm',
      musicGenre: 'Ambient',
    ),
    Mood(
      name: 'Adventure',
      emoji: '🌄',
      color: 'moodAdventure',
      musicGenre: 'Epic',
    ),
  ];
}