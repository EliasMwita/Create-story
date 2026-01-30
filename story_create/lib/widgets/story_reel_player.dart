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
        setState(() {
          _currentPage = (_currentPage + 1) % widget.story.imagePaths.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        });
      });
    }

    if (widget.story.musicPath != null) {
      _playMusic(widget.story.musicPath!);
    }
  }

  Future<void> _playMusic(String path) async {
    try {
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
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
                    ),
            ),

            // Template Overlay
            TemplateRegistry.getOverlay(templateId, borderRadius: 16),

            // Text Overlay
            Positioned(
              bottom: 60,
              left: 24,
              right: 24,
              child: Material(
                color: Colors.transparent,
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
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
