import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:story_create/models/mood_model.dart';
import 'package:story_create/widgets/mood_chip.dart';
import 'package:story_create/widgets/banner_ad_widget.dart';

class MoodStep extends StatefulWidget {
  final String? initialMood;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;

  const MoodStep({super.key, this.initialMood, required this.onNext, required this.onBack});

  @override
  State<MoodStep> createState() => _MoodStepState();
}

class _MoodStepState extends State<MoodStep> {
  late String? _selectedMood = widget.initialMood;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "What's the vibe?",
                  style: TextStyle(
                    fontSize: (size.width * 0.08).clamp(24.0, 32.0),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: isDark ? Colors.white : Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select a mood to set the tone and music for your story.',
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 32),
                // Mood Grid
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: Mood.moods.length,
                    itemBuilder: (context, index) {
                      final mood = Mood.moods[index];
                      final isSelected = _selectedMood == mood.name;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _selectedMood = mood.name;
                          });
                        },
                        child: MoodChip(mood: mood, isSelected: isSelected),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Center(child: BannerAdWidget()),
          const SizedBox(height: 16),

          // Navigation Buttons
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: widget.onBack,
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    widget.onNext({'mood': _selectedMood ?? 'Happy'});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedMood == null ? 'SKIP & CONTINUE' : 'CONTINUE',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
        ],
      ),
    );
  }
}
