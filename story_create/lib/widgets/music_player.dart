import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:story_create/services/audio_service.dart';

class MusicPlayer extends StatefulWidget {
  final String audioPath;
  final double initialVolume;
  final ValueChanged<double>? onVolumeChanged;

  const MusicPlayer({
    super.key,
    required this.audioPath,
    this.initialVolume = 100.0,
    this.onVolumeChanged,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final AudioService _audioService = AudioService();
  Duration? _duration;
  Duration _position = Duration.zero;
  double _volume = 100.0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _volume = widget.initialVolume;
    _initAudio();
  }

  Future<void> _initAudio() async {
    _duration = await _audioService.getAudioDuration(widget.audioPath);

    _audioService.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioService.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    setState(() {});
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioService.pauseAudio();
    } else {
      await _audioService.playAudio(widget.audioPath, volume: _volume / 100);
    }
  }

  void _updateVolume(double value) {
    setState(() {
      _volume = value;
    });
    _audioService.setVolume(value / 100);
    widget.onVolumeChanged?.call(value);
  }

  void _seekToPosition(double value) {
    final newPosition = Duration(
      milliseconds: (value * (_duration?.inMilliseconds ?? 0)).round(),
    );
    _audioService.seek(newPosition);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration != null && _duration!.inMilliseconds > 0
        ? _position.inMilliseconds / _duration!.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        children: [
          // Playback Controls
          Row(
            children: [
              // Play/Pause Button
              IconButton(
                onPressed: _togglePlay,
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(width: 16),

              // Progress Bar
              Expanded(
                child: Column(
                  children: [
                    Slider(
                      value: progress,
                      onChanged: _seekToPosition,
                      onChangeEnd: _seekToPosition,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          _formatDuration(_duration ?? Duration.zero),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Volume Control
          Row(
            children: [
              Icon(
                Icons.volume_up,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Slider(
                  value: _volume,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${_volume.round()}%',
                  onChanged: _updateVolume,
                ),
              ),
              Text(
                '${_volume.round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioService.stopAudio();
    super.dispose();
  }
}
