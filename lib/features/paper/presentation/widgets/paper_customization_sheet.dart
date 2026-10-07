import 'package:flutter/material.dart';

import '../../../../core/domain/value_objects/argb_color.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/paper_template.dart';
import 'paper_color_picker.dart';
import 'paper_orientation_selector.dart';
import 'paper_pattern_selector.dart';

/// Modal bottom sheet allowing full customization of paper pattern, background color, and orientation.
class PaperCustomizationSheet extends StatefulWidget {
  final PaperTemplate initialTemplate;
  final ValueChanged<PaperTemplate> onTemplateChanged;

  const PaperCustomizationSheet({
    super.key,
    required this.initialTemplate,
    required this.onTemplateChanged,
  });

  static Future<PaperTemplate?> show(
    BuildContext context, {
    required PaperTemplate initialTemplate,
    ValueChanged<PaperTemplate>? onLiveUpdate,
  }) {
    return showModalBottomSheet<PaperTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaperCustomizationSheet(
        initialTemplate: initialTemplate,
        onTemplateChanged: (template) {
          onLiveUpdate?.call(template);
        },
      ),
    );
  }

  @override
  State<PaperCustomizationSheet> createState() =>
      _PaperCustomizationSheetState();
}

class _PaperCustomizationSheetState extends State<PaperCustomizationSheet> {
  late PaperTemplate _currentTemplate;

  @override
  void initState() {
    super.initState();
    _currentTemplate = widget.initialTemplate;
  }

  void _updateTemplate(PaperTemplate newTemplate) {
    setState(() {
      _currentTemplate = newTemplate;
    });
    widget.onTemplateChanged(newTemplate);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('paper_customization_sheet'),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
            ),
          ),
          AppSpacing.gapLg,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paper Settings',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                key: const Key('close_paper_settings_button'),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(_currentTemplate),
              ),
            ],
          ),
          const Divider(),
          AppSpacing.gapMd,
          PaperPatternSelector(
            selectedPattern: _currentTemplate.pattern,
            onPatternChanged: (pattern) {
              _updateTemplate(_currentTemplate.copyWith(pattern: pattern));
            },
          ),
          AppSpacing.gapLg,
          PaperColorPicker(
            selectedColor: Color(_currentTemplate.backgroundColor.value),
            onColorChanged: (color) {
              _updateTemplate(
                _currentTemplate.copyWith(
                  backgroundColor: ArgbColor(color.toARGB32()),
                ),
              );
            },
          ),
          AppSpacing.gapLg,
          PaperOrientationSelector(
            selectedOrientation: _currentTemplate.orientation,
            onOrientationChanged: (orientation) {
              _updateTemplate(
                _currentTemplate.copyWith(orientation: orientation),
              );
            },
          ),
          AppSpacing.gapXl,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('apply_paper_template_button'),
              onPressed: () => Navigator.of(context).pop(_currentTemplate),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
