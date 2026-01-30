import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_create/models/story_model.dart';
import 'package:story_create/services/story_service.dart';
import 'package:story_create/services/video_service.dart';
import 'package:story_create/widgets/story_reel_player.dart';
import 'package:story_create/widgets/templates/template_registry.dart';

class PreviewStep extends StatefulWidget {
  final Map<String, dynamic> storyData;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  const PreviewStep({
    super.key,
    required this.storyData,
    required this.onBack,
    required this.onComplete,
  });

  @override
  State<PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<PreviewStep> {
  bool _isGenerating = false;
  double _progress = 0.0;
  
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _generateVideo() async {
    setState(() {
      _isGenerating = true;
      _progress = 0.0;
    });

    final images = widget.storyData['images'] as List<String>? ?? [];
    
    final newStory = StoryModel.create(
      title: widget.storyData['title'] as String? ?? 'My Story',
      description: widget.storyData['description'] as String? ?? '',
      mood: widget.storyData['mood'] as String? ?? 'Happy',
      place: widget.storyData['place'] as String? ?? 'No location',
      imagePaths: List<String>.from(images),
      musicPath: widget.storyData['music'] as String?,
      templateId: widget.storyData['template'] as String? ?? 'minimal',
    );

    // Call actual video generation
    final videoService = VideoService();
    final videoPath = await videoService.generateStoryVideo(newStory);

    if (!mounted) return;

    if (videoPath != null) {
      // Update story with actual video path
      final updatedStory = newStory.copyWith(videoOutputPath: videoPath);
      
      // Save story to Hive
      final storyService = Provider.of<StoryService>(context, listen: false);
      await storyService.addStory(updatedStory);

      setState(() {
        _isGenerating = false;
        _progress = 1.0;
      });

      _showSuccessDialog();
    } else {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to generate video. Please try again.')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Story Created', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Your story has been saved successfully.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              widget.onComplete(); // Navigate back/complete
            },
            child: const Text('AWESOME', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final templateId = widget.storyData['template'] ?? 'minimal';
    final template = TemplateRegistry.getTemplate(templateId);
    final bgColors = template.colors;
    
    // Create a temporary story model for the reel player
    final tempStory = StoryModel.create(
      title: widget.storyData['title'] as String? ?? 'YOUR TITLE',
      description: widget.storyData['description'] as String? ?? '',
      mood: widget.storyData['mood'] as String? ?? 'Happy',
      place: widget.storyData['place'] as String? ?? 'No location',
      imagePaths: List<String>.from(widget.storyData['images'] as List<String>? ?? []),
      musicPath: widget.storyData['music'] as String?,
      templateId: templateId,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. DYNAMIC BACKGROUND (Blurred Gradient)
          AnimatedContainer(
            duration: const Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: bgColors,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.black.withValues(alpha: 0.2)),
            ),
          ),

          // 2. THE STORY CANVAS (9:16 Ratio)
          Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: -5,
                  )
                ],
              ),
              child: Stack(
                children: [
                  StoryReelPlayer(story: tempStory),
                  
                  // Progress Overlay
                  if (_isGenerating)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                value: _progress,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. ACTION CONTROLS
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isGenerating ? null : widget.onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Edit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _generateVideo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _isGenerating ? 'Saving...' : 'Save & Share',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
