import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
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
  late String _previewId;
  Completer<String?>? _videoCompleter;

  @override
  void initState() {
    super.initState();
    _previewId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveStory() async {
    setState(() {
      _isGenerating = true;
    });

    final images = widget.storyData['images'] as List<String>? ?? [];
    
    final newStory = StoryModel.create(
      title: widget.storyData['title'] as String? ?? '',
      description: widget.storyData['description'] as String? ?? '',
      mood: widget.storyData['mood'] as String? ?? 'Happy',
      place: widget.storyData['place'] as String? ?? 'No location',
      imagePaths: List<String>.from(images),
      musicPath: widget.storyData['music'] as String?,
      templateId: widget.storyData['template'] as String? ?? 'minimal',
    );

    // 1. Save story to Hive immediately so it appears in the list
    final storyService = Provider.of<StoryService>(context, listen: false);
    await storyService.addStory(newStory);

    // 2. Reset and start video generation in background
    _videoCompleter = Completer<String?>();
    unawaited(_generateVideoInBackground(newStory, storyService));

    if (!mounted) return;

    setState(() {
      _isGenerating = false;
    });

    _showSuccessDialog(newStory);
  }

  Future<void> _generateVideoInBackground(StoryModel story, StoryService storyService) async {
    try {
      final videoPath = await VideoService().generateStoryVideo(story);
      if (videoPath != null) {
        story.videoOutputPath = videoPath;
        // Use direct save since it's a HiveObject and was already added to the box
        await story.save();
        // Notify listeners so UI (like HomeScreen) knows the video is ready
        storyService.refresh(); 
        _videoCompleter?.complete(videoPath);
      } else {
        _videoCompleter?.complete(null);
      }
    } catch (e) {
      debugPrint('Background video generation error: $e');
      _videoCompleter?.complete(null);
    }
  }

  void _showSuccessDialog(StoryModel story) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isBusy = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text('Story Created', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Your story has been saved! We are processing the cinematic video in the background.',
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                  if (isBusy) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    const Text('Preparing your reel video...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ],
              ),
              actions: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : () async {
                          setDialogState(() => isBusy = true);
                          
                          try {
                            String? videoPath = story.videoOutputPath;
                            if (videoPath == null && _videoCompleter != null) {
                              videoPath = await _videoCompleter!.future.timeout(
                                const Duration(seconds: 45), // Increased timeout for reliability
                                onTimeout: () => null,
                              );
                            }

                            if (videoPath != null && File(videoPath).existsSync()) {
                              // Share ONLY the video for maximum compatibility
                              await Share.shareXFiles(
                                [XFile(videoPath)],
                                text: '${story.title}\n\nCreated with @bst2026',
                                subject: story.title,
                              );
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Video is still processing or failed. Try sharing photos instead.')),
                                );
                              }
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => isBusy = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isBusy ? 'PROCESSING...' : 'SHARE REEL VIDEO', 
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : () async {
                          setDialogState(() => isBusy = true);
                          
                          try {
                            String? videoPath = story.videoOutputPath;
                            if (videoPath == null && _videoCompleter != null) {
                              videoPath = await _videoCompleter!.future.timeout(
                                const Duration(seconds: 45),
                                onTimeout: () => null,
                              );
                            }

                            if (videoPath != null && File(videoPath).existsSync()) {
                              await Gal.putVideo(videoPath);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Video saved to gallery!')),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Video is still processing or failed.')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error saving video: $e')),
                              );
                            }
                          } finally {
                            if (context.mounted) {
                              setDialogState(() => isBusy = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          isBusy ? 'PROCESSING...' : 'SAVE TO GALLERY', 
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isBusy ? null : () async {
                              final files = story.imagePaths.map((path) => XFile(path)).toList();
                              if (files.isNotEmpty) {
                                await Share.shareXFiles(
                                  files,
                                  text: '${story.title}\n\nCreated with @bst2026',
                                  subject: story.title,
                                );
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('SHARE PHOTOS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: isBusy ? null : () {
                              Navigator.pop(context);
                              widget.onComplete();
                            },
                            child: Text('DONE', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final templateId = widget.storyData['template'] ?? 'minimal';
    final template = TemplateRegistry.getTemplate(templateId);
    final bgColors = template.colors;
    
    // Create a temporary story model for the reel player with a stable ID
    final tempStory = StoryModel(
      id: _previewId,
      title: widget.storyData['title'] as String? ?? '',
      description: widget.storyData['description'] as String? ?? '',
      mood: widget.storyData['mood'] as String? ?? 'Happy',
      place: widget.storyData['place'] as String? ?? 'No location',
      date: DateTime.now(),
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
              child: Container(color: Colors.black.withValues(alpha: 0.3)),
            ),
          ),

          // 2. THE STORY CANVAS (9:16 Ratio)
          Center(
            child: Container(
              margin: EdgeInsets.all(size.width * 0.08),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 40,
                    spreadRadius: -10,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    StoryReelPlayer(story: tempStory),
                    
                    // Progress Overlay
                    if (_isGenerating)
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  value: null, // Indeterminate for a professional feel
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'CRAFTING YOUR STORY',
                                  style: const TextStyle(
                                    color: Colors.white, 
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                    fontSize: 10,
                                  ),
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
          ),

          // 3. ACTION CONTROLS
          Positioned(
            bottom: size.height * 0.05,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isGenerating ? null : widget.onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('EDIT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _saveStory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      _isGenerating ? 'SAVING...' : 'SAVE & SHARE',
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 12),
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
