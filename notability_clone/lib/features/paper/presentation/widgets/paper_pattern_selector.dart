import 'package:flutter/material.dart';
import '../../domain/models/paper_template.dart';

/// Segmented grid/list selector for paper pattern (Blank, Ruled, Grid, Dotted).
class PaperPatternSelector extends StatelessWidget {
  final PaperPattern selectedPattern;
  final ValueChanged<PaperPattern> onPatternChanged;

  const PaperPatternSelector({
    super.key,
    required this.selectedPattern,
    required this.onPatternChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paper Pattern',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: PaperPattern.values.map((pattern) {
            final isSelected = pattern == selectedPattern;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  key: Key('paper_pattern_${pattern.name}'),
                  onTap: () => onPatternChanged(pattern),
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pattern.icon,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          pattern.displayName,
                          style: TextStyle(
                            fontSize: 12,
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
