import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlaceStep extends StatefulWidget {
  final String? initialPlace;
  final Function(Map<String, dynamic>) onNext;
  final VoidCallback onBack;
  
  const PlaceStep({
    super.key,
    this.initialPlace,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PlaceStep> createState() => _PlaceStepState();
}

class _PlaceStepState extends State<PlaceStep> {
  late final _placeController = TextEditingController(text: widget.initialPlace);
  late bool _useLocation = widget.initialPlace == 'Current Location';
  
  @override
  void dispose() {
    _placeController.dispose();
    super.dispose();
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
                    'Location',
                    style: TextStyle(
                      fontSize: (size.width * 0.08).clamp(24.0, 32.0),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add a place to your story to remember where it happened.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Use Current Location Toggle
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Location',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Detect automatically',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _useLocation,
                          activeThumbColor: theme.colorScheme.primary,
                          onChanged: (value) {
                            setState(() {
                              _useLocation = value;
                              if (value) {
                                _placeController.text = 'Current Location';
                              } else {
                                _placeController.clear();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Manual Input
                  Text(
                    'Or enter manually',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _placeController,
                    enabled: !_useLocation,
                    decoration: InputDecoration(
                      hintText: 'e.g. Central Park, NY',
                      prefixIcon: Icon(
                        Icons.place_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Recent Places
                  Text(
                    'Suggested',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      {'name': 'Home', 'icon': Icons.home_rounded},
                      {'name': 'Office', 'icon': Icons.work_rounded},
                      {'name': 'Beach', 'icon': Icons.beach_access_rounded},
                      {'name': 'Mountain', 'icon': Icons.terrain_rounded},
                      {'name': 'Cafe', 'icon': Icons.coffee_rounded},
                    ].map((place) {
                      final isSelected = _placeController.text == place['name'];
                      return ChoiceChip(
                        label: Text(place['name'] as String),
                        avatar: Icon(
                          place['icon'] as IconData,
                          size: 16,
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _useLocation = false;
                            _placeController.text = selected ? (place['name'] as String) : '';
                          });
                        },
                        labelStyle: TextStyle(
                          color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selectedColor: theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : theme.colorScheme.outlineVariant,
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
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
                      'place': _placeController.text.trim().isNotEmpty
                          ? _placeController.text.trim()
                          : 'No location',
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
                    _placeController.text.trim().isEmpty ? 'SKIP & CONTINUE' : 'CONTINUE',
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