import 'dart:io';
import 'package:flutter/material.dart';

class ImageGridItem extends StatelessWidget {
  final String imagePath;
  final int index;
  final VoidCallback onRemove;
  final Function(int) onReorder;
  
  const ImageGridItem({
    super.key,
    required this.imagePath,
    required this.index,
    required this.onRemove,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.3),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
        
        // Top controls
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        
        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
        
        // Reorder handles (only show if multiple images)
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildReorderButton(Icons.arrow_back, index > 0, () {
                if (index > 0) {
                  onReorder(index - 1);
                }
              }),
              _buildReorderButton(Icons.arrow_forward, true, () {
                onReorder(index + 1);
              }),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildReorderButton(IconData icon, bool enabled, VoidCallback onTap) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: enabled ? Colors.black.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: enabled ? Colors.white : Colors.transparent,
            size: 16,
          ),
        ),
      ),
    );
  }
}