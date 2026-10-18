Read AGENTS.md and follow it completely.

Task: Replace the current Material icons with my custom icons from the
assets/icon/ folder. Change only these controls:

| Control                  | Custom icon to use      |
|--------------------------|-------------------------|
| Pen                      | the "pen" icon          |
| Pencil                   | the "pencil" icon       |
| Highlighter              | the "highlighter" icon  |
| Eraser                   | the "eraser" icon       |
| Shapes                   | the "shapes" icon       |
| Clear handwriting        | the "clear" icon        |
| Paper settings           | the "paper" icon        |

Change these controls everywhere they appear (the pen settings popover, the
expanded tools popover, the paper settings control wherever it lives now, and
any tooltip or selected-state use). Do NOT change any other icon.

STEP 1 (before any edit): inspect and report
- List every file in assets/icon/ with its format (svg or png) and size.
- Match each file to a control in the table. If a name is unclear or a file is
  missing, ask me. Do not guess.
- Find where each of the 7 controls is built in the code and which icon each uses now.
- Say whether assets/icon/ is already declared in pubspec.yaml.
- If the files are SVG, tell me whether the project already has an SVG package.
  If not, STOP and ask me before adding one (for example flutter_svg).
  If they are PNG, no new package is needed.

STEP 2: give me a short plan and wait for my OK
- Files you will create and change, and what you will not touch.

Permissions I give you now (nothing else):
- You may add the assets/icon/ declaration to the assets section of pubspec.yaml.
- You may create new files for the icon code.
- You may update existing tests that check the old icons. Do not delete any test.
  Tell me which tests you changed.

Quality rules (from context/code-standards.md):
- No hardcoded asset paths in widgets. Put all paths in one constants file
  (for example lib/core/constants/app_icons.dart).
- Make one small reusable icon widget in its own file so the 7 controls do not
  repeat code. Keep every file under 300 lines.
- Icons must follow the theme: correct color in light mode, dark mode, and for
  selected, disabled, and unselected states. Do not hardcode colors.
- Keep the same size as the current icons and a 48x48 touch target.
- Keep every tooltip and semantic label. Add one if it is missing.
- Add an error fallback so a missing or broken asset does not crash the app.
- Do not change behavior, layout, saved data, or the bottom toolbar logic.
- Do not leave unused imports, dead code, or the old icon code for these 7 controls.
- Do not edit platform folders.

When finished:
- Run dart format, flutter analyze, the related tests (note_editor_redesign_test
  and digital_writing_tools_test, then full flutter test).
- Update context/ui-context.md and progress-tracker.md if needed.
- Write the change-log entry with Before and After.
- Tell me what to check by hand: light and dark mode, selected and unselected
  tool, small phone, and every one of the 7 controls.

Stop after Step 1 and Step 2 and wait for my answer.