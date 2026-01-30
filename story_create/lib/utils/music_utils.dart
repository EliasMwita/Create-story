class MusicUtils {
  static String getMusicName(String path) {
    if (path.contains('calm_piano')) return 'Calm Piano';
    if (path.contains('upbeat_acoustic')) return 'Upbeat Acoustic';
    if (path.contains('epic_cinematic')) return 'Epic Cinematic';
    if (path.contains('romantic_strings')) return 'Romantic Strings';
    if (path.contains('motivational_rock')) return 'Motivational Rock';
    if (path.contains('melancholic_guitar')) return 'Melancholic Guitar';
    
    // Extract filename if it's a custom path
    if (path.contains('/')) {
      return path.split('/').last;
    }
    
    return 'Custom Music';
  }
}
