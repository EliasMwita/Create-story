import 'package:flutter/material.dart';
import 'steps/template_step.dart';
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
      if (!widget.isBlank) {'template': widget.initialTemplateId ?? 'minimal'}, // Step 0: SELECT STYLE
      {'images': [], 'order': []}, // Step 1 -> 0 if blank
      {'title': '', 'description': ''}, // Step 2 -> 1 if blank
      {'mood': ''}, // Step 3 -> 2 if blank
      {'place': ''}, // Step 4 -> 3 if blank
      {'music': null, 'volume': 100.0}, // Step 5 -> 4 if blank
      {}, // Step 6 -> 5 if blank: Preview
    ];

    _stepTitles = [
      if (!widget.isBlank) 'SELECT STYLE',
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalSteps = _stepTitles.length;

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
            fontSize: 14,
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
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation(
                    isDark ? Colors.white : Colors.black),
                minHeight: 3,
              );
            },
          ),

          // 2. Animated Header Information
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      key: ValueKey<int>(_currentStep),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'STEP ${_currentStep + 1} OF $totalSteps',
                          style: TextStyle(
                            color: isDark ? Colors.white38 : Colors.black38,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _stepTitles[_currentStep],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Percent Circle
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black),
                  ),
                  child: Text(
                    '${((_currentStep + 1) / totalSteps * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold),
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
                if (!widget.isBlank)
                  TemplateStep(
                    initialTemplateId: widget.initialTemplateId,
                    onNext: (data) {
                      _updateStepData(0, data);
                      _nextStep();
                    },
                  ),
                MediaStep(
                  onNext: (data) {
                    _updateStepData(widget.isBlank ? 0 : 1, data);
                    _nextStep();
                  },
                ),
                TextStep(
                  onNext: (data) {
                    _updateStepData(widget.isBlank ? 1 : 2, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                MoodStep(
                  onNext: (data) {
                    _updateStepData(widget.isBlank ? 2 : 3, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                PlaceStep(
                  onNext: (data) {
                    _updateStepData(widget.isBlank ? 3 : 4, data);
                    _nextStep();
                  },
                  onBack: _previousStep,
                ),
                MusicStep(
                  onNext: (data) {
                    _updateStepData(widget.isBlank ? 4 : 5, data);
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
