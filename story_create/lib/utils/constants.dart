import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'story_create';
  static const String appVersion = '1.0.0';

  // Video Settings
  static const int defaultVideoDuration = 15; // seconds
  static const int maxVideoDuration = 60; // seconds
  static const int imageDisplayDuration = 3; // seconds per image
  static const int maxImages = 10;
  static const String videoResolution = '1080x1920'; // Vertical video
  static const int videoFps = 30;

  // File Paths
  static const String storiesBoxName = 'stories';
  static const String appDocumentsFolder = 'story_create';
  static const String videoExportFolder = 'Videos';
  static const String imageExportFolder = 'Images';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double inputBorderRadius = 12.0;

  // Text Limits
  static const int maxTitleLength = 50;
  static const int maxDescriptionLength = 200;
  static const int maxCaptionLength = 100;
  static const int maxPlaceLength = 100;

  // Default Values
  static const String defaultMood = 'Happy';
  static const String defaultPlace = 'No location';
  static const double defaultMusicVolume = 100.0;

  // Transition Types
  static const List<String> transitionTypes = [
    'Fade',
    'Slide',
    'Zoom',
    'Blur',
    'Wipe',
  ];

  // Color Themes based on Mood
  static Map<String, Map<String, Color>> moodThemes = {
    'Happy': {
      'primary': Color(0xFFFFD166),
      'secondary': Color(0xFFFFF1C2),
      'text': Color(0xFF333333),
    },
    'Sad': {
      'primary': Color(0xFF118AB2),
      'secondary': Color(0xFFA2D2FF),
      'text': Color(0xFFFFFFFF),
    },
    'Romantic': {
      'primary': Color(0xFFEF476F),
      'secondary': Color(0xFFFFB4C2),
      'text': Color(0xFFFFFFFF),
    },
    'Motivational': {
      'primary': Color(0xFF06D6A0),
      'secondary': Color(0xFFC8F7E5),
      'text': Color(0xFF333333),
    },
    'Calm': {
      'primary': Color(0xFFA2D2FF),
      'secondary': Color(0xFFE2F0FF),
      'text': Color(0xFF333333),
    },
    'Adventure': {
      'primary': Color(0xFF8338EC),
      'secondary': Color(0xFFE0C8FF),
      'text': Color(0xFFFFFFFF),
    },
  };

  // Font Sizes
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // API Keys (would be loaded from environment in production)
  static const String ffmpegLicense = '';

  // Feature Flags
  static const bool enableCloudSync = false;
  static const bool enableAIFeatures = false;
  static const bool enableSocialSharing = true;
  static const bool enableVideoExport = true;

  // Validation Regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  // App URLs
  static const String privacyPolicyUrl = 'https://story_create.app/privacy';
  static const String termsOfServiceUrl = 'https://story_create.app/terms';
  static const String supportEmail = 'support@story_create.app';

  // Localization
  static const String defaultLocale = 'en';
  static const List<String> supportedLocales = ['en', 'es', 'fr', 'de', 'ja'];
}
