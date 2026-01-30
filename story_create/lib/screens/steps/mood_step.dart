import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:story_create/models/mood_model.dart';
import 'package:story_create/widgets/mood_chip.dart';

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
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What\'s the vibe?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a mood to set the tone and music for your story.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                // Mood Grid
                Expanded(
                  child: GridView.builder(
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

          const SizedBox(height: 16),

          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: widget.onBack,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _selectedMood == null
                      ? null
                      : () {
                          widget.onNext({'mood': _selectedMood!});
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
