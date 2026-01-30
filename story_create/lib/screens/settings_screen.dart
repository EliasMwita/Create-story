import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_create/services/preferences_service.dart';
import 'package:story_create/services/story_service.dart';
import 'package:story_create/utils/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefs = Provider.of<PreferencesService>(context);
    final storyService = Provider.of<StoryService>(context, listen: false);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          _buildSectionHeader(context, 'APPEARANCE'),
          _buildThemeSelector(context, prefs),
          const SizedBox(height: 32),
          
          _buildSectionHeader(context, 'DATA MANAGEMENT'),
          _buildListTile(
            context,
            title: 'Clear All Stories',
            subtitle: 'This will permanently delete all your saved stories',
            icon: Icons.delete_outline_rounded,
            iconColor: Colors.redAccent,
            onTap: () => _showClearConfirmation(context, storyService),
          ),
          const SizedBox(height: 32),
          
          _buildSectionHeader(context, 'ABOUT'),
          _buildListTile(
            context,
            title: 'App Version',
            subtitle: '1.0.0',
            icon: Icons.info_outline_rounded,
          ),
          _buildListTile(
            context,
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () {},
          ),
          _buildListTile(
            context,
            title: 'Terms of Service',
            icon: Icons.description_outlined,
            onTap: () {},
          ),
          
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.auto_stories, size: 40),
                ),
                const SizedBox(height: 12),
                Text(
                  'STORY CREATE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: isDark ? Colors.white38 : Colors.black38,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, PreferencesService prefs) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          _buildThemeOption(context, prefs, ThemeMode.system, 'System Default', Icons.brightness_auto_rounded),
          Divider(height: 1, indent: 56, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          _buildThemeOption(context, prefs, ThemeMode.light, 'Light Mode', Icons.light_mode_rounded),
          Divider(height: 1, indent: 56, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          _buildThemeOption(context, prefs, ThemeMode.dark, 'Dark Mode', Icons.dark_mode_rounded),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, PreferencesService prefs, ThemeMode mode, String title, IconData icon) {
    final isSelected = prefs.themeMode == mode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: () => prefs.setThemeMode(mode),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
            ? (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05))
            : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          size: 20, 
          color: isSelected 
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white38 : Colors.black38),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected 
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      trailing: isSelected 
        ? Icon(Icons.check_circle_rounded, size: 20, color: isDark ? Colors.white : Colors.black)
        : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor ?? (isDark ? Colors.white70 : Colors.black87)),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ) : null,
        trailing: onTap != null ? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white24 : Colors.black26) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, StoryService storyService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Stories?'),
        content: const Text('This action cannot be undone. All your creations will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              storyService.deleteAllStories();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All stories cleared')),
              );
            },
            child: const Text('DELETE ALL', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
