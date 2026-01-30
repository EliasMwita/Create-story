import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class MusicStep extends StatefulWidget {
  final String? initialMusic;
  final double? initialVolume;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  
  const MusicStep({
    super.key,
    this.initialMusic,
    this.initialVolume,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<MusicStep> createState() => _MusicStepState();
}

class _MusicStepState extends State<MusicStep> {
  late String? _selectedMusic = widget.initialMusic;
  String? _customMusicName;
  late double _volume = widget.initialVolume ?? 100.0;
  

  @override
  void initState() {
    super.initState();
    if (_selectedMusic != null) {
      if (_selectedMusic!.contains('recording')) {
        _customMusicName = 'My Recording';
      } else {
        _customMusicName = _selectedMusic!.split('/').last;
      }
    }
  }

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  Timer? _timer;
  int _recordDuration = 0;

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _recordDuration = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final String filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        // Explicit configuration for better voice pickup
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          numChannels: 1,
          sampleRate: 44100,
          bitRate: 128000,
        );
        
        await _audioRecorder.start(config, path: filePath);
        
        // Double check if it actually started
        bool recording = await _audioRecorder.isRecording();
        
        setState(() {
          _isRecording = recording;
        });
        
        if (recording) {
          _startTimer();
          HapticFeedback.heavyImpact();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Microphone permission denied')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording Error: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _stopTimer();
      setState(() {
        _isRecording = false;
        if (path != null) {
          _selectedMusic = path;
          _customMusicName = 'My Recording (${_formatDuration(_recordDuration)})';
        }
      });
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _pickMusic() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedMusic = result.files.single.path;
          _customMusicName = result.files.single.name;
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking music: $e')),
        );
      }
    }
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    bool isRecording = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuart,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isRecording 
              ? Colors.red.withValues(alpha: 0.1)
              : (isSelected 
                  ? theme.colorScheme.primary.withValues(alpha: 0.1) 
                  : (isDark ? Colors.white.withValues(alpha: 0.05) : theme.colorScheme.surface)),
          border: Border.all(
            color: isRecording 
                ? Colors.red.withValues(alpha: 0.5)
                : (isSelected 
                    ? theme.colorScheme.primary 
                    : (isDark ? Colors.white.withValues(alpha: 0.15) : theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
            width: isSelected || isRecording ? 2 : 1,
          ),
          boxShadow: isSelected || isRecording
              ? [
                  BoxShadow(
                    color: (isRecording ? Colors.red : theme.colorScheme.primary).withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRecording 
                    ? Colors.red 
                    : (isSelected 
                        ? theme.colorScheme.primary 
                        : (isDark ? Colors.white.withValues(alpha: 0.1) : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5))),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isRecording 
                    ? Colors.white 
                    : (isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      letterSpacing: -0.3,
                      color: isRecording 
                          ? Colors.red 
                          : (isSelected ? theme.colorScheme.primary : (isDark ? Colors.white : Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: isRecording 
                          ? Colors.red.withValues(alpha: 0.7) 
                          : (isSelected ? theme.colorScheme.primary.withValues(alpha: 0.7) : (isDark ? Colors.white38 : Colors.black38)),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected && !isRecording)
              Icon(
                Icons.check_circle_rounded,
                color: theme.colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Soundtrack',
                    style: TextStyle(
                      fontSize: (size.width * 0.08).clamp(24.0, 32.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a layer of emotion to your story with a custom track or voice recording.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Primary Actions
                  _buildActionCard(
                    context,
                    title: _customMusicName != null && _selectedMusic != null && !_selectedMusic!.startsWith('assets/') && _customMusicName != 'My Recording' 
                        ? _customMusicName! 
                        : 'Import Audio',
                    subtitle: 'PICK FROM YOUR DEVICE',
                    icon: Icons.library_music_rounded,
                    isSelected: _customMusicName != null && _selectedMusic != null && !_selectedMusic!.startsWith('assets/') && _customMusicName != 'My Recording',
                    onTap: _pickMusic,
                  ),
                  const SizedBox(height: 16),
                  _buildActionCard(
                    context,
                    title: _isRecording 
                        ? 'Recording... ${_formatDuration(_recordDuration)}' 
                        : (_customMusicName == 'My Recording' ? _customMusicName! : 'Voice Memo'),
                    subtitle: _isRecording ? 'TAP TO STOP' : 'USE MICROPHONE',
                    icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    isSelected: _customMusicName == 'My Recording',
                    isRecording: _isRecording,
                    onTap: () {
                      if (_isRecording) {
                        _stopRecording();
                      } else {
                        _startRecording();
                      }
                    },
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Volume Control
          if (_selectedMusic != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.volume_up_rounded, size: 16, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'VOLUME',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Text(
                        '${_volume.round()}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                      activeTrackColor: theme.colorScheme.primary,
                      inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      thumbColor: theme.colorScheme.primary,
                    ),
                    child: Slider(
                      value: _volume,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _volume = value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          
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
                    widget.onNext({
                      'music': _selectedMusic,
                      'volume': _volume,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.white : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedMusic == null ? 'SKIP & CONTINUE' : 'CONTINUE',
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
