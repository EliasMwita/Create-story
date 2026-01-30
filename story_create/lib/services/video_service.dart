import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
//import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_create/models/story_model.dart';

class VideoService {
  static final VideoService _instance = VideoService._internal();
  
  factory VideoService() {
    return _instance;
  }
  
  VideoService._internal();
  
  Future<String?> generateStoryVideo(StoryModel story) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final outputPath = '${appDir.path}/story_${story.id}.mp4';
      
      final tempDir = await getTemporaryDirectory();
      // Create temporary directory for intermediate files
      final framesDir = '${tempDir.path}/frames_${story.id}';
      await Directory(framesDir).create(recursive: true);
      
      // Prepare FFmpeg command
      final command = _buildFFmpegCommand(story, framesDir, outputPath);
      
      // Execute FFmpeg command
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        // Clean up temporary files
        await Directory(framesDir).delete(recursive: true);
        return outputPath;
      } else {
        final logs = await session.getLogsAsString();
        final output = await session.getOutput();
        print('Video generation failed logs: $logs');
        print('Video generation failed output: $output');
        return null;
      }
    } catch (e) {
      print('Error generating video: $e');
      return null;
    }
  }
  
  String _buildFFmpegCommand(
    StoryModel story,
    String framesDir,
    String outputPath,
  ) {
    final images = story.imagePaths;
    const double durationPerImage = 3.0; // seconds per image
    const double transitionDuration = 0.5; // seconds for transition
    
    final command = StringBuffer();
    
    // Input images
    for (int i = 0; i < images.length; i++) {
      command.write('-loop 1 -t $durationPerImage -i "${images[i]}" ');
    }
    
    // Add music if exists
    if (story.musicPath != null) {
      command.write('-i "${story.musicPath}" ');
    }
    
    // Video filter complex
    command.write('-filter_complex "');
    
    // 1. Scale and prepare each input
    for (int i = 0; i < images.length; i++) {
      command.write('[$i:v]scale=1080:1920:force_original_aspect_ratio=decrease,'
          'pad=1080:1920:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v$i]; ');
    }
    
    // 2. Apply transitions (xfade)
    // We combine them sequentially: [v0][v1]xfade -> [t0]; [t0][v2]xfade -> [t1]; etc.
    if (images.length > 1) {
      String lastOutput = '[v0]';
      for (int i = 0; i < images.length - 1; i++) {
        final String currentOutput = '[t$i]';
        // Offset is cumulative: each image adds (duration - transition)
        final double offset = (i + 1) * (durationPerImage - transitionDuration);
        
        command.write('$lastOutput[v${i + 1}]xfade=transition=fade:duration=$transitionDuration:offset=$offset$currentOutput; ');
        lastOutput = currentOutput;
      }
      // Final video stream name
      command.write('" -map "[t${images.length - 2}]" ');
    } else {
      // Single image, no transitions
      command.write('" -map "[v0]" ');
    }
    
    // Add audio if exists
    if (story.musicPath != null) {
      command.write('-map ${images.length}:a ');
      command.write('-shortest '); // Trim audio to video length
      command.write('-c:a aac -b:a 256k '); // High quality audio
    } else {
      command.write('-an '); // No audio
    }
    
    // Output settings - High Quality
    command.write(
      '-c:v libx264 '
      '-preset medium '
      '-crf 18 '
      '-pix_fmt yuv420p '
      '-movflags +faststart '
      '-y ' 
      '"$outputPath"'
    );
    
    return command.toString();
  }
  
  Future<String?> addTextOverlay(
    String videoPath,
    String text,
    String position,
    int startTime,
    int duration,
  ) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/overlay_${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      // Escape text for FFmpeg
      final escapedText = text.replaceAll("'", "'\\\\\\''").replaceAll('"', '\\"');
      
      final command = '''
        -i "$videoPath" 
        -vf "
          drawtext=
            text='$escapedText':
            fontfile=/system/fonts/Roboto-Regular.ttf:
            fontsize=48:
            fontcolor=white:
            borderw=3:
            bordercolor=black:
            x=(w-text_w)/2:
            y=(h-text_h)*0.8:
            enable='between(t,$startTime,${startTime + duration})'
        " 
        -c:a copy 
        -y 
        "$outputPath"
      ''';
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return outputPath;
      }
      return null;
    } catch (e) {
      print('Error adding text overlay: $e');
      return null;
    }
  }
  
  Future<void> trimVideo(
    String inputPath,
    String outputPath,
    int startSecond,
    int duration,
  ) async {
    try {
      final command = '''
        -i "$inputPath" 
        -ss $startSecond 
        -t $duration 
        -c copy 
        -y 
        "$outputPath"
      ''';
      
      final session = await FFmpegKit.execute(command);
      await session.getReturnCode();
    } catch (e) {
      print('Error trimming video: $e');
    }
  }
  
  Future<Duration?> getVideoDuration(String videoPath) async {
    try {
      final command = '''
        -v error 
        -show_entries format=duration 
        -of default=noprint_wrappers=1:nokey=1 
        "$videoPath"
      ''';
      
      final session = await FFmpegKit.execute(command);
      final output = await session.getOutput();
      
      if (output != null) {
        final duration = double.tryParse(output);
        if (duration != null) {
          return Duration(milliseconds: (duration * 1000).round());
        }
      }
      return null;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    }
  }
  
  Future<String> getVideoThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final command = '''
        -i "$videoPath" 
        -ss 00:00:01 
        -vframes 1 
        -vf "scale=320:-1" 
        -y 
        "$thumbnailPath"
      ''';
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        return thumbnailPath;
      }
      return '';
    } catch (e) {
      print('Error getting thumbnail: $e');
      return '';
    }
  }
}