import 'package:flutter/material.dart';
import 'package:notability_clone/core/constants/app_constants.dart';
import 'package:notability_clone/core/constants/app_icons.dart';
import 'package:notability_clone/core/theme/app_spacing.dart';
import 'package:notability_clone/core/widgets/app_icon.dart';
import 'package:notability_clone/features/canvas/domain/models/writing_tool.dart';
import 'package:notability_clone/features/editor/presentation/widgets/editor_shape_toolbar_options.dart';
import 'package:notability_clone/features/editor/presentation/widgets/editor_toolbar_button.dart';

enum _EditorToolbarMode { normal, tools, shapeOptions }

/// Switches between the editor's main actions and its compact tool controls.
class EditorFloatingToolbar extends StatefulWidget {
  const EditorFloatingToolbar({
    super.key,
    required this.toolConfig,
    required this.isTextMode,
    required this.isListening,
    required this.isRecording,
    required this.isPanMode,
    required this.isPenMode,
    required this.isPenSettingsOpen,
    required this.isAddContentOpen,
    required this.onActivateTextMode,
    required this.onToggleVoiceInput,
    required this.onShowAddContent,
    required this.onToggleHandwriting,
    required this.onTogglePan,
    required this.onTogglePenSettings,
    required this.onSelectTool,
    required this.onSelectShapeType,
    required this.onToggleShapeFill,
    required this.onToggleRecording,
    required this.onClearHandwriting,
    required this.onEnterToolsMode,
  });

  final ToolConfig toolConfig;
  final bool isTextMode;
  final bool isListening;
  final bool isRecording;
  final bool isPanMode;
  final bool isPenMode;
  final bool isPenSettingsOpen;
  final bool isAddContentOpen;
  final VoidCallback onActivateTextMode;
  final VoidCallback onToggleVoiceInput;
  final VoidCallback onShowAddContent;
  final VoidCallback onToggleHandwriting;
  final VoidCallback onTogglePan;
  final VoidCallback onTogglePenSettings;
  final ValueChanged<WritingToolType> onSelectTool;
  final ValueChanged<ShapeType> onSelectShapeType;
  final VoidCallback onToggleShapeFill;
  final VoidCallback onToggleRecording;
  final VoidCallback onClearHandwriting;
  final VoidCallback onEnterToolsMode;

  @override
  State<EditorFloatingToolbar> createState() => _EditorFloatingToolbarState();
}

class _EditorFloatingToolbarState extends State<EditorFloatingToolbar> {
  _EditorToolbarMode _mode = _EditorToolbarMode.normal;

  static const _tools = <(WritingToolType, String, String)>[
    (WritingToolType.pen, AppIcons.pen, AppConstants.pen),
    (WritingToolType.pencil, AppIcons.pencil, AppConstants.pencil),
    (
      WritingToolType.highlighter,
      AppIcons.highlighter,
      AppConstants.highlighter,
    ),
    (WritingToolType.eraser, AppIcons.eraser, AppConstants.eraser),
    (WritingToolType.shape, AppIcons.shapes, AppConstants.shapes),
    (WritingToolType.ruler, '', AppConstants.ruler),
  ];

  Widget _normalButtons() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      EditorToolbarButton(
        buttonKey: const Key('text_tool_button'),
        tooltip: widget.isTextMode
            ? AppConstants.finishTyping
            : AppConstants.typeOnCanvas,
        icon: const Icon(Icons.text_fields),
        label: AppConstants.textToolLabel,
        active: widget.isTextMode,
        onPressed: widget.onActivateTextMode,
      ),
      EditorToolbarButton(
        buttonKey: const Key('voice_input_button'),
        tooltip: widget.isListening
            ? AppConstants.stopVoiceInput
            : AppConstants.voiceInput,
        icon: Icon(widget.isListening ? Icons.mic : Icons.mic_none),
        active: widget.isListening,
        onPressed: widget.onToggleVoiceInput,
      ),
      EditorToolbarButton(
        buttonKey: const Key('add_content_button'),
        tooltip: AppConstants.addContent,
        icon: const Icon(Icons.add),
        active: widget.isAddContentOpen,
        onPressed: widget.onShowAddContent,
      ),
      EditorToolbarButton(
        buttonKey: const Key('handwriting_tool_button'),
        tooltip: AppConstants.handwritingDrawing,
        icon: const Icon(Icons.gesture),
        active: widget.isPenMode,
        onPressed: widget.onToggleHandwriting,
      ),
      EditorToolbarButton(
        buttonKey: const Key('pan_tool_button'),
        tooltip: widget.isPanMode
            ? AppConstants.finishPanning
            : AppConstants.panPage,
        icon: const Icon(Icons.pan_tool_alt),
        active: widget.isPanMode,
        onPressed: widget.onTogglePan,
      ),
      EditorToolbarButton(
        buttonKey: const Key('pen_tool_button'),
        tooltip: AppConstants.penSettings,
        icon: const AppIcon(AppIcons.pen),
        active: widget.isPenSettingsOpen,
        onPressed: widget.onTogglePenSettings,
      ),
    ],
  );

  Widget _toolsButtons() => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      ..._tools.map((tool) {
        final (type, iconPath, label) = tool;
        return EditorToolbarButton(
          buttonKey: Key('toolbar_tool_${type.name}'),
          tooltip: label,
          icon: iconPath.isEmpty
              ? const Icon(Icons.straighten)
              : AppIcon(iconPath),
          active: widget.toolConfig.toolType == type,
          onPressed: () {
            widget.onSelectTool(type);
            if (type == WritingToolType.shape) {
              setState(() => _mode = _EditorToolbarMode.shapeOptions);
            }
          },
        );
      }),
      EditorToolbarButton(
        buttonKey: const Key('toolbar_record_audio_button'),
        tooltip: widget.isRecording
            ? AppConstants.stopAudioRecording
            : AppConstants.recordAudio,
        icon: Icon(widget.isRecording ? Icons.stop : Icons.mic),
        active: widget.isRecording,
        onPressed: widget.onToggleRecording,
      ),
      EditorToolbarButton(
        buttonKey: const Key('clear_canvas_button'),
        tooltip: AppConstants.clearHandwriting,
        icon: const AppIcon(AppIcons.clear),
        onPressed: widget.onClearHandwriting,
      ),
    ],
  );

  Widget _shapeButtons() => EditorShapeToolbarOptions(
    selectedShape: widget.toolConfig.shapeType,
    isFilled: widget.toolConfig.filled,
    onSelectShape: widget.onSelectShapeType,
    onToggleFill: widget.onToggleShapeFill,
  );

  @override
  Widget build(BuildContext context) => Material(
    key: const Key('floating_editor_toolbar'),
    color: Theme.of(context).colorScheme.surface,
    elevation: AppSpacing.floatingControlElevation,
    shadowColor: Theme.of(context).colorScheme.shadow
        .withValues(alpha: AppSpacing.floatingControlShadowAlpha),
    borderRadius: BorderRadius.circular(AppSpacing.floatingControlCornerRadius),
    child: Container(
      padding: const EdgeInsets.all(AppSpacing.floatingControlPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          AppSpacing.floatingControlCornerRadius,
        ),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            switch (_mode) {
              _EditorToolbarMode.normal => _normalButtons(),
              _EditorToolbarMode.tools => _toolsButtons(),
              _EditorToolbarMode.shapeOptions => _shapeButtons(),
            },
            EditorToolbarButton(
              buttonKey: const Key('expand_tools_button'),
              tooltip: _mode == _EditorToolbarMode.normal
                  ? AppConstants.moreTools
                  : AppConstants.back,
              icon: AppIcon(
                _mode == _EditorToolbarMode.normal
                    ? AppIcons.circleArrowRight
                    : AppIcons.arrowLeft,
              ),
              active: _mode != _EditorToolbarMode.normal,
              onPressed: () {
                if (_mode == _EditorToolbarMode.normal) {
                  widget.onEnterToolsMode();
                  setState(() => _mode = _EditorToolbarMode.tools);
                } else if (_mode == _EditorToolbarMode.shapeOptions) {
                  setState(() => _mode = _EditorToolbarMode.tools);
                } else {
                  setState(() => _mode = _EditorToolbarMode.normal);
                }
              },
            ),
          ],
        ),
      ),
    ),
  );
}
