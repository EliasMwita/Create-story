import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/story_model.dart';
import 'services/story_service.dart';
import 'services/preferences_service.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(StoryModelAdapter());
  await Hive.openBox<StoryModel>('stories');
  await Hive.openBox('preferences');

  runApp(const StoryCreateApp());
}

class StoryCreateApp extends StatelessWidget {
  const StoryCreateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StoryService()),
        ChangeNotifierProvider(create: (_) => PreferencesService()),
      ],
      child: Consumer<PreferencesService>(
        builder: (context, prefs, child) {
          return MaterialApp(
            title: 'story_create',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: prefs.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
