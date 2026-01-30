---
description: Repository Information Overview
alwaysApply: true
---

# story_create Information

## Summary
`story_create` is a minimalist mobile application for creating stories, built using the Flutter framework. It features local data persistence with Hive, state management using Provider, and media processing capabilities through FFmpeg and various audio/video plugins.

## Structure
- **lib/**: Core application logic and UI components.
  - **models/**: Data structures including `StoryModel`.
  - **screens/**: Application screens (e.g., `HomeScreen`, `steps/`).
  - **services/**: Business logic and data services like `StoryService`.
  - **utils/**: Shared utilities, themes, and constants.
  - **widgets/**: Reusable UI components.
- **assets/**: Static resources including images and background music.
- **test/**: Test suite for widgets and business logic.
- **android/, ios/, linux/, macos/, web/, windows/**: Platform-specific configuration and build files for cross-platform support.

## Language & Runtime
**Language**: Dart  
**Version**: SDK >=3.0.0 <4.0.0  
**Build System**: Flutter Build System  
**Package Manager**: pub (via `pubspec.yaml`)

## Dependencies
**Main Dependencies**:
- `provider`: State management.
- `hive` & `hive_flutter`: Lightweight local database.
- `ffmpeg_kit_flutter`: Media manipulation.
- `video_player` & `audioplayers`: Media playback.
- `flutter_svg`: Vector graphics support.
- `smooth_page_indicator`: UI navigation.
- `photo_view`: Image interaction.
- `image_picker` & `file_picker`: Media selection.

**Development Dependencies**:
- `flutter_test`: Testing framework.
- `flutter_lints`: Static analysis.
- `build_runner`: Code generation (for Hive adapters).
- `hive_generator`: Hive adapter generation.

## Build & Installation
```bash
# Install dependencies
flutter pub get

# Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the application
flutter run

# Build for specific platform (e.g., Android)
flutter build apk
```

## Testing
**Framework**: `flutter_test` (based on JUnit style)
**Test Location**: `test/`
**Naming Convention**: `*_test.dart`
**Configuration**: `pubspec.yaml` (dev_dependencies)

**Run Command**:
```bash
flutter test
```
