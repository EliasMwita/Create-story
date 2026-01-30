import 'package:flutter/material.dart';
import 'package:story_create/screens/create_story_screen.dart';
import 'package:story_create/utils/colors.dart';
import 'package:story_create/widgets/templates/template_registry.dart';

class TemplateCategoryScreen extends StatelessWidget {
  final String categoryName;
  final String templateId;

  const TemplateCategoryScreen({
    super.key,
    required this.categoryName,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final template = TemplateRegistry.getTemplate(templateId);
    
    // Responsive sizing
    final double horizontalPadding = size.width * 0.06;
    final double cardHeight = (size.height * 0.55).clamp(380.0, 500.0);
    final double titleFontSize = (size.width * 0.08).clamp(28.0, 36.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: isDark ? Colors.white : Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            fontSize: 14,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Style',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start creating with our hand-crafted ${categoryName.toLowerCase()} template.',
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateStoryScreen(
                      initialTemplateId: templateId,
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'template_$templateId',
                child: Container(
                  height: cardHeight,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: template.colors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: template.colors.first.withValues(alpha: 0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Icon
                      Positioned(
                        right: -40,
                        bottom: -40,
                        child: Icon(
                          template.icon,
                          size: size.width * 0.6,
                          color: template.textColor.withValues(alpha: 0.05),
                        ),
                      ),
                      // Overlay Graphics
                      TemplateRegistry.getOverlay(templateId, borderRadius: 32),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: template.textColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: template.textColor.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                template.tag,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: template.textColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              template.name,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w900,
                                color: template.textColor,
                                height: 1.0,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: template.textColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.bolt_rounded, 
                                    size: 14, color: template.textColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PRO STYLE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: template.textColor,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Use Template Button
                      Positioned(
                        bottom: 32,
                        right: 32,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.black, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Style Highlights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailItem(context, Icons.auto_awesome_mosaic_rounded, 'Seamless Layouts', 'Automatically adapts to your media aspect ratio.'),
            _buildDetailItem(context, Icons.auto_awesome_rounded, 'Smart Motion', 'Kinetic typography and fluid transitions.'),
            _buildDetailItem(context, Icons.volume_up_rounded, 'Immersive Audio', 'Audio normalization and vibe-matched soundtracks.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, IconData icon, String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: isDark ? Colors.white : Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
