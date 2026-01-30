import 'package:flutter/material.dart';
import 'steps/media_step.dart';
import 'steps/text_step.dart';
import 'steps/mood_step.dart';
import 'steps/place_step.dart';
import 'steps/music_step.dart';
import 'steps/preview_step.dart';

class CreateStoryScreen extends StatefulWidget {
  final String? initialTemplateId;
  final bool isBlank;
  const CreateStoryScreen({super.key, this.initialTemplateId, this.isBlank = false});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Initializing story data structure
  late final List<Map<String, dynamic>> _storyData;
  late final List<String> _stepTitles;

  @override
  void initState() {
    super.initState();
    _storyData = [
      {'template': widget.isBlank ? 'none' : (widget.initialTemplateId ?? 'minimal')},
      {'images': [], 'order': []}, // Step 0: IMPORT MEDIA
      {'title': '', 'description': ''}, // Step 1: STORY DETAILS
      {'mood': ''}, // Step 2: SET THE VIBE
      {'place': ''}, // Step 3: TAG LOCATION
      {'music': null, 'volume': 100.0}, // Step 4: ADD SOUNDTRACK
      {}, // Step 5: FINAL PREVIEW
    ];

    _stepTitles = [
      'IMPORT MEDIA',
      'STORY DETAILS',
      'SET THE VIBE',
      'TAG LOCATION',
      'ADD SOUNDTRACK',
      'FINAL PREVIEW',
    ];
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart, // Smoother, more professional curve
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void _updateStepData(int step, Map<String, dynamic> data) {
    setState(() {
      _storyData[step].addAll(data);
    });
  }

  Map<String, dynamic> _getStoryData() {
    final data = <String, dynamic>{};
    for (var step in _storyData) {
      data.addAll(step);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalSteps = _stepTitles.length;
    
    // Responsive sizing
    final double horizontalPadding = size.width * 0.06;
    final double titleFontSize = (size.width * 0.055).clamp(20.0, 26.0);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EDITOR',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
            fontSize: 12,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Sleek Progress Bar
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween<double>(begin: 0, end: (_currentStep + 1) / totalSteps),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation(
                    isDark ? Colors.white : Colors.black),
                minHeight: 2,
              );
            },
          ),

          // 2. Animated Header Information
          Padding(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey<int>(_currentStep),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP ${_currentStep + 1} OF $totalSteps',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stepTitles[_currentStep],
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Percent Circle
                Container(
                  height: 44,
                  width: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                        width: 1.5,
                    ),
                  ),
                  child: Text(
                    '${((_currentStep + 1) / totalSteps * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Step Content (PageView)
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                MediaStep(
                  initialImages: List<String>.from(_storyData[1]['images'] ?? []),
                  onNext: (data) {
                    _updateStepData(1, data);
                    _nextStep();
                  },
                ),
                TextStep(
                  initialTitle: _storyData[2]['title'],
                  initialDescription: _storyData[2]['description'],
                  onNext: (data) {
                    _updateStepData(2, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                MoodStep(
                  initialMood: _storyData[3]['mood'],
                  onNext: (data) {
                    _updateStepData(3, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                PlaceStep(
                  initialPlace: _storyData[4]['place'],
                  onNext: (data) {
                    _updateStepData(4, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                MusicStep(
                  initialMusic: _storyData[5]['music'],
                  initialVolume: _storyData[5]['volume'],
                  onNext: (data) {
                    _updateStepData(5, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                PreviewStep(
                  storyData: _getStoryData(),
                  onBack: _previousStep,
                  onComplete: () {
                    // Final Logic: Save to Service and Close
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
