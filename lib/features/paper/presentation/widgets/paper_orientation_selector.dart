import 'package:flutter/material.dart';
import '../../domain/models/paper_template.dart';

/// Toggle selector for Page Orientation (Portrait / Landscape).
class PaperOrientationSelector extends StatelessWidget {
  final PageOrientation selectedOrientation;
  final ValueChanged<PageOrientation> onOrientationChanged;

  const PaperOrientationSelector({
    super.key,
    required this.selectedOrientation,
    required this.onOrientationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Page Orientation',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: PageOrientation.values.map((orientation) {
            final isSelected = orientation == selectedOrientation;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  key: Key('orientation_${orientation.name}'),
                  onTap: () => onOrientationChanged(orientation),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor.withAlpha(25)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          orientation.icon,
                          size: 20,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          orientation.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
