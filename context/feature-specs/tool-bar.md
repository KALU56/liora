Read AGENTS.md and follow it completely.

Task: Change the "More tools (arrow)" behavior in the floating editor toolbar
(widget _EditorToolActions).

CURRENT behavior: tapping the arrow opens a popover that lists Pen, Pencil,
Highlighter, Eraser, Shapes, Ruler, Record audio / Stop audio recording, and
Clear handwriting.

WANTED behavior:
1. Tapping the arrow does NOT open a popover anymore.
2. Instead, the toolbar switches to "tools mode": the tool controls appear
   inside the toolbar itself, in the place of the normal items (Type on canvas
   "Tt", Voice input, and the other normal items).
3. The arrow icon changes to the arrow-left icon (assets/icon, my custom
   arrow-left svg), in the same position.
4. Tapping arrow-left returns the toolbar to the normal mode, and the arrow
   icon returns to the original arrow.
5. Tool behavior itself does not change (selecting a tool, settings, ruler,
   record audio, clear handwriting all work as today).

STEP 1 (before any edit): inspect and report
- Read _EditorToolActions and where the toolbar and the expanded tools popover
  are built. Tell me the file, its line count, and which controls the toolbar
  has in normal mode.
- Tell me exactly which controls you think should be replaced in tools mode
  and which should stay. I mean "text" and "audio/voice" but I am not sure
  what you will find. Ask me to confirm, do not guess.
- Check that assets/icon/ has the arrow-left icon and what the file is called.
  If it is missing or the name is unclear, ask me.
- Check how icons are loaded now (my custom icon task: constants file, icon
  widget, SVG package). Reuse that. Do not add a second way.
- Tell me how the toolbar will fit on a narrow phone, in landscape, and with
  larger text, when 8 tools are shown in one row (scroll, wrap, or fewer items).
  Recommend one option.
- Tell me what should happen to: the pen settings popover (colors, width,
  opacity, eraser size, shape type, fill), the Ruler overlay, an active
  Record audio session, and text mode or voice input that is running when the
  user switches mode. Recommend one behavior for each.
- Tell me if the mode must be reset when the page changes or the editor closes.

STEP 2: give me a short plan and wait for my OK
- Files you will create and change, and what you will not touch.

Permissions I give you now (nothing else):
- You may create new files for this (for example a widget for the tools mode
  row and a small state holder).
- You may update existing tests that depend on the old popover. Do not delete
  any test. Tell me which tests you changed.

Quality rules (context/code-standards.md):
- Do NOT make new_note_screen.dart bigger. Put the new UI and state in new
  small files. Every file you create or change stays under 300 lines.
- No hardcoded asset paths, sizes, colors, strings, or durations. Use
  constants and theme tokens.
- Keep tooltips and semantic labels. The arrow and arrow-left need a tooltip
  ("More tools" and "Back"), 48x48 touch target, and correct theme colors in
  light and dark mode.
- Selected, unselected, and disabled states stay visible for every tool.
- A smooth short switch animation is allowed only if it is simple, uses a
  constant duration, and does not slow the app. Otherwise no animation.
- No overflow warnings at any width. The toolbar must not cover the page more
  than today or block drawing.
- Remove the old popover code that is no longer used. No dead code or
  unused imports.
- Do not change saved data, tool behavior, or platform folders.

When finished:
- Add widget tests: tap arrow -> tools show and normal items hide; arrow-left
  icon shows; tap arrow-left -> normal toolbar returns; a tool can be selected
  in tools mode; narrow layout has no overflow.
- Run dart format, flutter analyze, note_editor_redesign_test and
  digital_writing_tools_test, then full flutter test.
- Update context/ui-context.md (section 4 and the pen settings section) and
  progress-tracker.md.
- Write the change-log entry with Before and After.
- Tell me what to check by hand.

Stop after Step 1 and Step 2 and wait for my answer.