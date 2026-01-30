import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class MusicStep extends StatefulWidget {
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  
  const MusicStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<MusicStep> createState() => _MusicStepState();
}

class _MusicStepState extends State<MusicStep> {
  String? _selectedMusic;
  String? _customMusicName;
  double _volume = 100.0;
  
  final List<Map<String, dynamic>> _musicOptions = [];

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
                  'Soundtrack',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a track to set the mood for your story.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Music Selection Grid
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _musicOptions.length + 2,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isPicked = _customMusicName != null && _selectedMusic != null && !_selectedMusic!.startsWith('assets/') && _customMusicName != 'My Recording';
                        final isSelected = isPicked;
                        
                        return GestureDetector(
                          onTap: _pickMusic,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                                  : theme.colorScheme.surface,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  if (!isSelected)
                                    CustomPaint(
                                      painter: _DashedBorderPainter(
                                        color: theme.colorScheme.outlineVariant,
                                        radius: 20,
                                      ),
                                      child: Container(),
                                    ),
                                  
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isSelected ? Icons.file_present_rounded : Icons.add_rounded,
                                            size: 18,
                                            color: isSelected
                                                ? theme.colorScheme.onPrimary
                                                : theme.colorScheme.primary,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isSelected ? _customMusicName! : 'Pick from device',
                                              style: theme.textTheme.labelLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? theme.colorScheme.primary
                                                    : theme.colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              isSelected ? 'LOCAL FILE' : 'YOUR OWN MUSIC',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: isSelected
                                                    ? theme.colorScheme.primary.withValues(alpha: 0.7)
                                                    : theme.colorScheme.onSurfaceVariant,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 20,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (index == 1) {
                        final isRecorded = _customMusicName == 'My Recording';
                        final isSelected = isRecorded;
                        
                        return GestureDetector(
                          onTap: () {
                            if (_isRecording) {
                              _stopRecording();
                            } else {
                              _startRecording();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isRecording 
                                    ? Colors.red 
                                    : (isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                                width: (isSelected || _isRecording) ? 2 : 1,
                              ),
                              color: _isRecording 
                                  ? Colors.red.withValues(alpha: 0.1) 
                                  : (isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2) : theme.colorScheme.surface),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _isRecording 
                                              ? Colors.red 
                                              : (isSelected ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                          size: 18,
                                          color: (_isRecording || isSelected)
                                              ? Colors.white
                                              : theme.colorScheme.primary,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isRecording 
                                                ? 'Recording... ${_formatDuration(_recordDuration)}' 
                                                : (isSelected ? _customMusicName! : 'Record Voice'),
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _isRecording 
                                                  ? Colors.red 
                                                  : (isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _isRecording ? 'TAP TO STOP' : 'USE MICROPHONE',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: _isRecording 
                                                  ? Colors.red.withValues(alpha: 0.7) 
                                                  : (isSelected ? theme.colorScheme.primary.withValues(alpha: 0.7) : theme.colorScheme.onSurfaceVariant),
                                              fontSize: 8,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected && !_isRecording)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }

                      final music = _musicOptions[index - 2];
                      final isSelected = _selectedMusic == music['path'] && _customMusicName == null;
                      
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _selectedMusic = music['path'];
                            // Clear custom music name if an asset is selected
                            if (music['path'].startsWith('assets/')) {
                              _customMusicName = null;
                            }
                          });
                        },
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: isSelected ? 1.02 : 1.0,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                                  : theme.colorScheme.surface,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              children: [
                                if (isSelected)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isSelected ? Icons.play_arrow_rounded : Icons.music_note_rounded,
                                        size: 18,
                                        color: isSelected
                                            ? theme.colorScheme.onPrimary
                                            : theme.colorScheme.primary,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          music['name'],
                                          style: theme.textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          music['genre'].toUpperCase(),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isSelected
                                                ? theme.colorScheme.primary.withValues(alpha: 0.7)
                                                : theme.colorScheme.onSurfaceVariant,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Volume Control
          if (_selectedMusic != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.volume_up, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Volume',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${_volume.round()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _volume,
                    min: 0,
                    max: 100,
                    divisions: 10,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.primaryContainer,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          
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
                  onPressed: () {
                    widget.onNext({
                      'music': _selectedMusic,
                      'volume': _volume,
                    });
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

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
        Radius.circular(radius),
      ));

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    var distance = 0.0;
    final dashPath = Path();

    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}