import 'package:flutter/material.dart';

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
        left: 20.0,
        right: 20.0,
        top: 16.0,
        bottom: MediaQuery.of(context).padding.bottom + 20.0,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Paper Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                key: const Key('close_paper_settings_button'),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(_currentTemplate),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12.0),
          PaperPatternSelector(
            selectedPattern: _currentTemplate.pattern,
            onPatternChanged: (pattern) {
              _updateTemplate(_currentTemplate.copyWith(pattern: pattern));
            },
          ),
          const SizedBox(height: 20.0),
          PaperColorPicker(
            selectedColor: _currentTemplate.backgroundColor,
            onColorChanged: (color) {
              _updateTemplate(
                _currentTemplate.copyWith(backgroundColor: color),
              );
            },
          ),
          const SizedBox(height: 20.0),
          PaperOrientationSelector(
            selectedOrientation: _currentTemplate.orientation,
            onOrientationChanged: (orientation) {
              _updateTemplate(
                _currentTemplate.copyWith(orientation: orientation),
              );
            },
          ),
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('apply_paper_template_button'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(_currentTemplate),
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
