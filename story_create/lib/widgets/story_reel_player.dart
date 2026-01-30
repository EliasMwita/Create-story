import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:story_create/models/story_model.dart';
import 'package:story_create/utils/music_utils.dart';
import 'package:story_create/widgets/templates/template_registry.dart';

class StoryReelPlayer extends StatefulWidget {
  final StoryModel story;
  final bool autoPlay;

  const StoryReelPlayer({
    super.key,
    required this.story,
    this.autoPlay = true,
  });

  @override
  State<StoryReelPlayer> createState() => _StoryReelPlayerState();
}

class _StoryReelPlayerState extends State<StoryReelPlayer> {
  late final PageController _pageController;
  late final AudioPlayer _audioPlayer;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _audioPlayer = AudioPlayer();
    if (widget.autoPlay) {
      _startPlayback();
    }
  }

  @override
  void didUpdateWidget(StoryReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if story data changed
    final bool storyChanged = widget.story.id != oldWidget.story.id ||
        widget.story.imagePaths.length != oldWidget.story.imagePaths.length ||
        widget.story.musicPath != oldWidget.story.musicPath ||
        widget.story.templateId != oldWidget.story.templateId;

    bool contentChanged = storyChanged;
    if (!contentChanged && widget.story.imagePaths.isNotEmpty) {
      for (int i = 0; i < widget.story.imagePaths.length; i++) {
        if (widget.story.imagePaths[i] != oldWidget.story.imagePaths[i]) {
          contentChanged = true;
          break;
        }
      }
    }

    if (contentChanged) {
      _timer?.cancel();
      _audioPlayer.stop();
      _currentPage = 0;
      if (widget.autoPlay) {
        _startPlayback();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startPlayback() {
    if (widget.story.imagePaths.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted) return;
        if (widget.story.imagePaths.isEmpty) return;
        
        setState(() {
          _currentPage = (_currentPage + 1) % widget.story.imagePaths.length;
          if (_pageController.hasClients) {
            _pageController.animateToPage(
              _currentPage,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        });
      });
    }

    if (widget.story.musicPath != null) {
      _playMusic(widget.story.musicPath!);
    }
  }

  Future<void> _playMusic(String path) async {
    try {
      await _audioPlayer.stop();
      if (path.startsWith('assets/')) {
        await _audioPlayer.play(AssetSource(path.replaceFirst('assets/', '')));
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      debugPrint('Error playing music in reel: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final templateId = widget.story.templateId ?? 'minimal';
    
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Material(
        type: MaterialType.transparency,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // PageView for Media Reel
              Positioned.fill(
                child: widget.story.imagePaths.isNotEmpty
                    ? PageView.builder(
                        controller: _pageController,
                        itemCount: widget.story.imagePaths.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Image.file(
                            File(widget.story.imagePaths[index]),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Image not found',
                                      style: TextStyle(
                                        color: Colors.grey, 
                                        fontSize: 12,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
                      ),
              ),

              // Template Overlay
              TemplateRegistry.getOverlay(templateId, borderRadius: 16),

              // Small Branding Logo
              Positioned(
                top: 20,
                left: 20,
                child: Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // "Created with @bst2026" Watermark
              Positioned(
                bottom: 20,
                right: 24,
                child: Opacity(
                  opacity: 0.7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 12,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '@bst2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Text Overlay
              Positioned(
                bottom: 60,
                left: 24,
                right: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.story.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        decoration: TextDecoration.none,
                        shadows: [
                          Shadow(
                            blurRadius: 15,
                            color: Colors.black,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                    ),
                    if (widget.story.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        widget.story.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                          height: 1.4,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black.withValues(alpha: 0.8),
                              offset: const Offset(0, 1),
                            )
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Music Badge
              if (widget.story.musicPath != null)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.music_note, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          MusicUtils.getMusicName(widget.story.musicPath!),
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 10,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
