import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_create/models/template_model.dart';
import 'package:story_create/services/story_service.dart';
import 'package:story_create/screens/create_story_screen.dart';
import 'package:story_create/screens/template_category_screen.dart';
import 'package:story_create/widgets/story_card.dart';
import 'package:story_create/widgets/template_preview_card.dart';
import 'package:story_create/utils/colors.dart';
import 'package:story_create/widgets/templates/template_registry.dart';
import 'package:story_create/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  List<TemplateModel> _shuffledTemplates = [];
  Timer? _shuffleTimer;

  @override
  void initState() {
    super.initState();
    _initializeTemplates();
    _startShuffleTimer();
  }

  @override
  void dispose() {
    _shuffleTimer?.cancel();
    super.dispose();
  }

  void _startShuffleTimer() {
    _shuffleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _initializeTemplates();
      }
    });
  }

  void _initializeTemplates() {
    final templates = TemplateRegistry.allTemplates.where((t) => t.id != 'none').toList();
    templates.shuffle();
    setState(() {
      _shuffledTemplates = templates;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Responsive sizing
    final double horizontalPadding = size.width * 0.06; // 6% of width
    final double titleFontSize = (size.width * 0.07).clamp(24.0, 32.0);
    final double subtitleFontSize = (size.width * 0.035).clamp(12.0, 16.0);
    
    // Get templates from registry, excluding 'none' for categories
    final templates = TemplateRegistry.allTemplates.where((t) => t.id != 'none').toList();
    final categories = ['All', ...templates.map((t) => t.name.split(' ').last)]; 

    // Use shuffled templates for Explore section if available
    final exploreTemplates = _shuffledTemplates.isNotEmpty ? _shuffledTemplates : templates;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Modern Header with Greeting
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontalPadding, 60, horizontalPadding, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.auto_stories,
                              color: isDark ? Colors.white70 : Colors.black87,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Create Story.',
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : Colors.black,
                                  letterSpacing: -1,
                                  height: 1.1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        size: 22,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Refined Categories
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                        if (index > 0) {
                          final template = templates[index - 1];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TemplateCategoryScreen(
                                categoryName: template.name,
                                templateId: template.id,
                              ),
                            ),
                          );
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected 
                            ? (isDark ? Colors.white : Colors.black)
                            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected 
                              ? (isDark ? Colors.black : Colors.white)
                              : (isDark ? Colors.white60 : Colors.black54),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Explore Styles Section
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Text(
                    'Explore Styles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: exploreTemplates.length,
                itemBuilder: (context, index) {
                  final template = exploreTemplates[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TemplatePreviewCard(
                      template: template,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateStoryScreen(
                              initialTemplateId: template.id,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Start Blank Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateStoryScreen(isBlank: true),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 16,
                          color: isDark ? Colors.white : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'START FROM BLANK',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Stories Header
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 40, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Your Stories',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Stories Grid
          Consumer<StoryService>(
            builder: (context, storyService, child) {
              final stories = storyService.stories.reversed.toList();

              if (stories.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.auto_stories_outlined,
                            size: 40,
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No stories yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white24 : Colors.black26,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 9 / 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return StoryCard(story: stories[index]);
                    },
                    childCount: stories.length,
                  ),
                ),
              );
            },
          ),

          // Bottom Spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}
