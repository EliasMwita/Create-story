import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:story_create/widgets/templates/template_registry.dart';

class TemplateStep extends StatefulWidget {
  final String? initialTemplateId;
  final Function(Map<String, dynamic>) onNext;

  const TemplateStep({super.key, this.initialTemplateId, required this.onNext});

  @override
  State<TemplateStep> createState() => _TemplateStepState();
}

class _TemplateStepState extends State<TemplateStep> {
  late String _selectedTemplateId = widget.initialTemplateId ?? 'minimal';

  @override
  void didUpdateWidget(TemplateStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTemplateId != oldWidget.initialTemplateId &&
        widget.initialTemplateId != null) {
      setState(() {
        _selectedTemplateId = widget.initialTemplateId!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templates = TemplateRegistry.allTemplates;
    final selectedTemplate = TemplateRegistry.getTemplate(_selectedTemplateId);

    return Column(
      children: [
        // Grid of Templates
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75, // Story-like portrait ratio
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final isSelected = _selectedTemplateId == template.id;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOutQuint,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _selectedTemplateId = template.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    transform: isSelected
                        ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
                        : Matrix4.diagonal3Values(0.96, 0.96, 1.0),
                    transformAlignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: template.colors
                            .map((c) => c.withValues(alpha: isSelected ? 0.5 : 0.3))
                            .toList(),
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: template.colors.first.withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                      ],
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Stack(
                          children: [
                            // Template Overlay Layer
                            TemplateRegistry.getOverlay(template.id),
                            // Visual Icon Background
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: Icon(
                                template.icon,
                                size: 100,
                                color: template.textColor.withValues(alpha: 0.1),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: template.textColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      template.tag,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: template.textColor,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    template.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: template.textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Checkmark Overlay
                            if (isSelected)
                              const Positioned(
                                top: 12,
                                right: 12,
                                child: Icon(Icons.check_circle, color: Colors.blueAccent, size: 28),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Action Bar
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Style',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      selectedTemplate.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () => widget.onNext({'template': _selectedTemplateId}),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Next Step'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
