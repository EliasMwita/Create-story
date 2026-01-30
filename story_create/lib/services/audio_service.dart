import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentFilePath;
  
  AudioService._();
  static final AudioService _instance = AudioService._();
  
  factory AudioService() => _instance;
  
  Future<String?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        return result.files.single.path;
      }
      return null;
    } catch (e) {
      print('Error picking audio file: $e');
      return null;
    }
  }
  
  Future<String?> trimAudio(
    String inputPath,
    double startSeconds,
    double endSeconds,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/trimmed_${DateTime.now().millisecondsSinceEpoch}.mp3';
      
      // This would use FFmpeg in production
      // For now, we'll just copy the file as a placeholder
      final inputFile = File(inputPath);
      await inputFile.copy(outputPath);
      
      return outputPath;
    } catch (e) {
      print('Error trimming audio: $e');
      return null;
    }
  }
  
  Future<void> playAudio(String filePath, {double volume = 1.0}) async {
    try {
      if (_isPlaying && _currentFilePath == filePath) {
        await pauseAudio();
        return;
      }
      
      if (_isPlaying) {
        await stopAudio();
      }
      
      await _audioPlayer.play(DeviceFileSource(filePath), volume: volume);
      _isPlaying = true;
      _currentFilePath = filePath;
      
      _audioPlayer.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }
  
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
    } catch (e) {
      print('Error pausing audio: $e');
    }
  }
  
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _currentFilePath = null;
    } catch (e) {
      print('Error stopping audio: $e');
    }
  }
  
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      print('Error setting volume: $e');
    }
  }
  
  Future<Duration?> getAudioDuration(String filePath) async {
    try {
      final tempPlayer = AudioPlayer();
      await tempPlayer.setSource(DeviceFileSource(filePath));
      final duration = await tempPlayer.getDuration();
      await tempPlayer.dispose();
      return duration;
    } catch (e) {
      print('Error getting audio duration: $e');
      return null;
    }
  }
  
  Stream<Duration> get onPositionChanged => _audioPlayer.onPositionChanged;
  Stream<PlayerState> get onPlayerStateChanged => _audioPlayer.onPlayerStateChanged;
  
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking audio: $e');
    }
  }
  
  bool get isPlaying => _isPlaying;
  String? get currentFilePath => _currentFilePath;
  
  Future<void> dispose() async {
    await stopAudio();
    await _audioPlayer.dispose();
  }
  
  // Built-in royalty-free music tracks
  static final List<Map<String, dynamic>> builtInTracks = [];
  
  List<Map<String, dynamic>> getTracksByMood(String mood) {
    return builtInTracks.where((track) => track['mood'] == mood).toList();
  }
  
  List<String> getAllGenres() {
    final genres = builtInTracks.map((track) => track['genre'] as String).toSet();
    return genres.toList();
  }
}