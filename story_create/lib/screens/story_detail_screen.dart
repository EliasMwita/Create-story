import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:story_create/models/story_model.dart';
import 'package:story_create/services/story_service.dart';
import 'package:story_create/models/mood_model.dart';
import 'package:story_create/utils/music_utils.dart';
import 'package:story_create/widgets/story_video_player.dart';
import 'package:story_create/widgets/story_reel_player.dart';
import 'package:story_create/utils/colors.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  late StoryModel? _story;
  bool _isLoading = true;
  bool _isPreviewing = false;

  @override
  void initState() {
    super.initState();
    _loadStory();
  }

  Future<void> _loadStory() async {
    final storyService = Provider.of<StoryService>(context, listen: false);
    setState(() {
      _story = storyService.getStory(widget.storyId);
      _isLoading = false;
    });
  }

  void _shareStory() async {
    if (_story == null) return;
    
    final story = _story!;
    final List<XFile> files = [];
    
    // 1. Add video if available
    if (story.videoOutputPath != null && File(story.videoOutputPath!).existsSync()) {
      files.add(XFile(story.videoOutputPath!));
    }
    
    // 2. Add all images
    for (final path in story.imagePaths) {
      if (File(path).existsSync()) {
        files.add(XFile(path));
      }
    }
    
    if (files.isEmpty) {
      await Share.share(
        '${story.title}\n\n${story.description}\n\nCreated with @bst2026',
        subject: story.title,
      );
    } else {
      await Share.shareXFiles(
        files,
        text: '${story.title}\n\n${story.description}\n\nCreated with @bst2026',
        subject: story.title,
      );
    }
  }

  void _deleteStory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Story'),
        content: const Text(
          'Are you sure you want to delete this story? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final storyService = Provider.of<StoryService>(
                context,
                listen: false,
              );
              storyService.deleteStory(widget.storyId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _playVideo() {
    setState(() {
      _isPreviewing = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_story == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: Text('Story not found')),
      );
    }

    final story = _story!;
    final double horizontalPadding = size.width * 0.06;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: size.height * 0.5,
                pinned: true,
                stretch: true,
                backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? Colors.black45 : Colors.white70,
                    foregroundColor: isDark ? Colors.white : Colors.black,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.black45 : Colors.white70,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: _shareStory,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? Colors.black45 : Colors.white70,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                    ),
                    onPressed: _deleteStory,
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      StoryReelPlayer(
                        story: story,
                        autoPlay: true,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black38,
                              Colors.transparent,
                              Colors.transparent,
                              Colors.black54,
                            ],
                            stops: [0.0, 0.2, 0.7, 1.0],
                          ),
                        ),
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: _playVideo,
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                                ),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Mood.fromName(story.mood).actualColor,
                            ),
                            child: Text(
                              story.mood.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('MMM dd, yyyy').format(story.date).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        story.title,
                        style: TextStyle(
                          fontSize: (size.width * 0.08).clamp(28.0, 36.0),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                          color: isDark ? Colors.white : Colors.black,
                          height: 1.1,
                        ),
                      ),
                      if (story.description.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          story.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: isDark ? Colors.white70 : Colors.black87,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                      if (story.place.isNotEmpty && story.place != 'No location') ...[
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'LOCATION',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.2,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      story.place,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 48),
                      if (story.imagePaths.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '${story.imagePaths.length} ITEMS',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white24 : Colors.black26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GridView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                          itemCount: story.imagePaths.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(story.imagePaths[index]),
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                      if (story.musicPath != null) ...[
                        const Text(
                          'Soundtrack',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white10 : Colors.black87,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      MusicUtils.getMusicName(story.musicPath!),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Ambient audio track',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: FilledButton.icon(
                          onPressed: _playVideo,
                          icon: const Icon(Icons.play_arrow_rounded, size: 28),
                          label: const Text(
                            'Watch Story',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isPreviewing)
          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: story.videoOutputPath != null
                        ? StoryVideoPlayer(
                            videoPath: story.videoOutputPath!,
                          )
                        : StoryReelPlayer(
                            story: story,
                          ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 16,
                    right: 16,
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        setState(() {
                          _isPreviewing = false;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
