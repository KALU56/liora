# Change Log

## 2026-10-19: Simplify Pen settings
- **Before:** The Pen settings popover included tool switching, shape controls, and a Fine pen shortcut alongside drawing settings.
- **After:** Tool switching stays in toolbar mode; Pen settings shows color, width, and opacity. Shape controls stay in the Shape toolbar row, and Eraser keeps its size control.
- **Why:** Keep the settings panel focused on the selected tool's drawing adjustments.
- **Files changed:** `lib/features/editor/presentation/editor_popover_actions.dart`, `lib/features/editor/presentation/editor_tool_actions.dart`, `test/digital_writing_tools_test.dart`, `test/note_editor_redesign_test.dart`, `context/ui-context.md`, `context/change-log.md`.
- **Tests run:** `flutter test test/digital_writing_tools_test.dart test/note_editor_redesign_test.dart` passed (28 tests); `flutter analyze` reported no issues; Dart formatting check passed.
- **Check by hand:** Open Pen settings and confirm the color, Width, and Opacity controls are present with no Pencil or Highlighter choices. Select Eraser and confirm Small/Large size remains available.
- **Needs your attention:** None.

## 2026-10-19: Add nested shape options to the toolbar
- **Before:** Tapping Shapes selected the tool but left no in-toolbar way to choose a specific shape type or fill.
- **After:** Shapes opens a nested row with Line, Rectangle, Square, Oval, Circle, Triangle, Arrow, and Fill controls. Back returns to the tools row, and Back again returns to normal mode.
- **Why:** Keep shape selection and settings within the toolbar navigation the user requested.
- **Files changed:** `lib/core/constants/app_constants.dart`, `lib/features/editor/presentation/editor_toolbar_actions.dart`, `lib/features/editor/presentation/widgets/editor_floating_toolbar.dart`, `lib/features/editor/presentation/widgets/editor_toolbar_button.dart` (added), `lib/features/editor/presentation/widgets/editor_shape_toolbar_options.dart` (added), `test/note_editor_redesign_test.dart`, `context/ui-context.md`, `context/progress-tracker.md`, `context/change-log.md`.
- **Tests run:** `dart format` passed; `flutter analyze` passed with no issues; focused editor, writing-tool, and canvas tests passed (40 tests); full `flutter test` passed (99 tests).
- **Check by hand:** Enter tools mode, tap Shapes, choose a shape and toggle Fill, then use Back once to return to tools and again to return to normal.
- **Needs your attention:** On narrow screens, swipe horizontally to reach Back when the current row is wider than the display.

## 2026-10-19: Keep tools mode open after selecting a tool
- **Before:** Selecting a writing tool or clearing handwriting returned the floating toolbar to normal mode.
- **After:** Tools mode remains open after tool selection and clearing; only the left arrow returns to normal mode.
- **Why:** Keep the tool controls available while switching between tools.
- **Files changed:** `lib/features/editor/presentation/widgets/editor_floating_toolbar.dart`, `test/note_editor_redesign_test.dart`, `test/handwriting_canvas_test.dart`, `context/ui-context.md`, `context/progress-tracker.md`, `context/change-log.md`.
- **Tests run:** `dart format` passed; `flutter analyze` passed with no issues; focused editor, writing-tool, and canvas tests passed (40 tests); full `flutter test` passed (99 tests).
- **Check by hand:** Enter tools mode, select Highlighter and another tool, clear handwriting, and confirm the toolbar stays in tools mode until you tap the left arrow.
- **Needs your attention:** None.

## 2026-10-19: Switch the floating toolbar to tools mode
- **Before:** More tools opened a popover above the toolbar with the writing tools, ruler, audio recording, and clear actions.
- **After:** More tools switches the toolbar row to those eight controls and shows the custom left arrow. Back restores the normal row. Tool selection and clear return to normal mode; recording remains in tools mode so it can be stopped. The row scrolls horizontally on narrow layouts.
- **Why:** Keep the editor tools inside the floating toolbar while preserving their actions.
- **Files changed:** `lib/core/constants/app_constants.dart`, `lib/core/constants/app_icons.dart`, `lib/core/theme/app_spacing.dart`, `lib/features/editor/presentation/editor_popover_actions.dart`, `lib/features/editor/presentation/editor_session_state.dart`, `lib/features/editor/presentation/editor_toolbar_actions.dart`, `lib/features/editor/presentation/new_note_screen.dart`, `lib/features/editor/presentation/widgets/editor_floating_toolbar.dart` (added), `test/digital_writing_tools_test.dart`, `test/editor_media_flow_test.dart`, `test/note_editor_redesign_test.dart`, `context/ui-context.md`, `context/progress-tracker.md`, `context/change-log.md`.
- **Tests run:** `dart format` passed; `flutter analyze` passed with no issues; focused toolbar, writing tool, media, and canvas tests passed (51 tests); full `flutter test` passed (99 tests).
- **Check by hand:** Switch between normal and tools mode; swipe the tools row to reach Back on a narrow phone; select each writing tool and check its selected state; test the ruler, start and stop recording, clear handwriting, and confirm active text/voice behavior remains as expected.
- **Needs your attention:** On narrow screens the Back control follows the tools and may require horizontal scrolling to reach.

## 2026-10-18: Use circle arrow for More tools
- **Before:** The More tools button showed a plain forward arrow.
- **After:** The button shows the custom circle-arrow SVG.
- **Why:** Match the button to the custom icon set.
- **Files changed:** `lib/core/constants/app_icons.dart`, `lib/features/editor/presentation/editor_toolbar_actions.dart`, `test/digital_writing_tools_test.dart`, `context/ui-context.md`, `context/change-log.md`.
- **Tests run:** `dart format` passed; `flutter analyze` passed with no issues; `flutter test test/digital_writing_tools_test.dart` passed (16 tests).
- **Check by hand:** Open the editor and confirm More tools shows the circle arrow and still opens the expanded tools.
- **Needs your attention:** None.

## 2026-10-18: Use custom SVG icons for editor controls
- **Before:** Pen, Pencil, Highlighter, Eraser, Shapes, Clear handwriting, and Paper settings used Material icons.
- **After:** These seven controls use themed SVG assets through a shared icon widget with a Material fallback; labels, touch targets, and actions are preserved.
- **Why:** Apply the custom icon set consistently across the editor controls.
- **Files changed:** `lib/core/constants/app_icons.dart` (added), `lib/core/widgets/app_icon.dart` (added), `lib/features/canvas/presentation/widgets/writing_tool_selector.dart`, `lib/features/editor/presentation/editor_popover_actions.dart`, `lib/features/editor/presentation/editor_toolbar_actions.dart`, `lib/features/editor/presentation/editor_workspace.dart`, `lib/features/editor/presentation/new_note_screen.dart`, `pubspec.yaml`, `pubspec.lock`, `test/digital_writing_tools_test.dart`, `test/note_editor_redesign_test.dart`, `context/ui-context.md`, `context/change-log.md`.
- **Tests run:** `dart format` passed; `flutter analyze` passed with no issues; focused editor and writing tools tests passed (28 tests); full `flutter test` passed (99 tests).
- **Check by hand:** Check light and dark mode, selected and unselected tools, a small phone layout, and all seven controls: Pen, Pencil, Highlighter, Eraser, Shapes, Clear handwriting, and Paper settings.
- **Needs your attention:** None.

## 2026-10-17: Set screen and widget file organization rules
- **Before:** Screen naming and reusable widget placement were not stated as explicit project rules.
- **After:** Screens use `*_screen.dart` under `presentation/`; reusable widgets use individual files under `presentation/widgets/`. `main.dart` is the root app exception.
- **Why:** Keep screen coordination separate from reusable UI components.
- **Files changed:** `context/code-standards.md`, `context/change-log.md`.
- **Tests run:** Not run; documentation-only change. Audited existing widget and screen class paths.
- **Check by hand:** None.
- **Needs your attention:** None. Existing screen and reusable widget classes already follow the rule.

## 2026-10-17: Keep only open issues in the tracker
- **Before:** `current-issues.md` repeated resolved issues that were already documented in the change log.
- **After:** Removed resolved entries from the current tracker, retained ISSUE-017 as open, and clarified that resolved issues belong in the change log.
- **Why:** Keep the current issue list focused on outstanding work while preserving history.
- **Files changed:** `context/current-issues.md`, `context/change-log.md`.
- **Tests run:** Not run; documentation-only edit.
- **Check by hand:** Confirm the tracker lists only ISSUE-017 and resolved issues remain in prior change-log entries.
- **Needs your attention:** ISSUE-017 still needs target-device permission verification.

## 2026-10-17: Finish remaining maintenance fixes
- **Before:** Existing attachment paths were not portable, editor session fields lived directly on the screen state, and recorder/speech/playback startup failures had test gaps.
- **After:** Readable old attachment paths migrate to SQLite blobs for both snapshot migration and existing database rows; editor session data is grouped in `EditorSessionState`; plugin failure flows have widget tests and recorder state resets after failure.
- **Why:** Resolve the remaining code and automated-test issues from the maintenance list.
- **Files changed:** `lib/features/notes/data/note_attachment_storage.dart`, `lib/features/notes/data/repositories/sqlite_note_storage.dart`, `lib/features/editor/presentation/`, `test/note_persistence_test.dart`, `test/editor_media_flow_test.dart`, `context/current-issues.md`, `context/architecture-context.md`, `context/progress-tracker.md`, `context/change-log.md`.
- **Tests run:** `flutter test` passed (99 tests); Chrome widget smoke test passed (2 tests); focused attachment, SQLite, and media tests passed; `flutter analyze` reported no issues; `flutter build web --release` succeeded.
- **Check by hand:** On a target device, open a note with an old attachment, confirm it opens after restart, then test image/file/audio picking and microphone/speech permissions.
- **Needs your attention:** ISSUE-017 remains open because this workspace has Linux and Chrome only, with no Android/iOS device or emulator. The Linux build also needs host GStreamer development files.

## 2026-10-17: Resolve maintenance issues and migrate note storage
- **Before:** Notes used one SharedPreferences snapshot; attachment paths lived outside note data; Drift had no web runtime assets; `context/` was ignored by Git.
- **After:** Notes save as individual SQLite rows with a safe one-time snapshot migration. New attachments are SQLite blobs, the editor shows a missing-blob fallback, and Drift web assets/config are present. The context directory is trackable.
- **Why:** Fix large-notebook persistence, improve attachment safety, enable web SQLite, and preserve project context in version control.
- **Files changed:** `lib/features/notes/data/`, `lib/features/notes/data/note_attachment_storage.dart`, `lib/core/dependencies/app_dependencies.dart`, editor/library attachment flows, `pubspec.yaml`, `pubspec.lock`, `web/sqlite3.wasm` (added), `web/drift_worker.js` (added), `.gitignore`, tests, and `context/` documentation.
- **Tests run:** `flutter test` passed (93 tests); focused SQLite/attachment tests passed; `flutter analyze` passed with no issues; `flutter build web --release` produced `build/web/index.html`. Added a file-backed SQLite restart test.
- **Check by hand:** On target devices, add an image, file, and recording; close/reopen the app; open attachments; delete a note with shared and unshared attachments. Legacy path-based attachments still need migration.
- **Needs your attention:** ISSUE-002 remains in progress for legacy path migration; ISSUE-003, ISSUE-014, and ISSUE-017 remain incomplete. Linux build requires the host GStreamer development package; this workspace has Linux and Chrome only.

## 2026-10-17: Resolve editor and note maintenance issues
- **Before:** The editor was stored under the library feature and mixed UI actions with plugin calls; undo, pan, search, thumbnails, deletion, and attachment handling had the gaps recorded in `current-issues.md`.
- **After:** Moved the editor into `features/editor` with a compatibility export, extracted focused UI/action part files and injectable media/storage services, added stroke-style undo, drawing-only labels, pan mode, content search, first-page previews, trash recovery, and opening non-audio files. Local attachment cleanup now preserves shared references. Storage remains unchanged as requested.
- **Why:** Address the maintenance issues while preserving existing note snapshots and following the user's product choices.
- **Files changed:** Editor, canvas, library, note model/repository/storage/widgets, app routing/dependencies/theme, related tests, and `context/current-issues.md`, `context/architecture-context.md`, `context/ui-context.md`, `context/progress-tracker.md` (existing in-progress changes from the same authorized maintenance task retained).
- **Tests run:** `flutter analyze` passed with 0 issues; `flutter test` passed (87 tests); `flutter test --coverage` passed (87 tests); `dart format --set-exit-if-changed lib test` completed, formatting one changed theme file.
- **Check by hand:** Try add/pan/draw flows, trash and restore a note, permanently delete a note with an attachment, open a non-audio file, and verify image/audio/speech permissions and behavior on each supported device.
- **Needs your attention:** Large-notebook storage is deferred per your choice. Attachment backup/missing-file recovery and some plugin error cases remain open. Real media, microphone, and speech platform checks still need device access; editor transient state can be decomposed further.


Newest entry on TOP. The AI must add one entry after every task.

## Entry format

```
## YYYY-MM-DD: Short title
- **Before:** how it worked / looked / was written before
- **After:** how it works / looks / is written now
- **Why:** the reason for the change
- **Files changed:** list of files
- **Tests run:** test files and result (or "not run" + reason)
- **Check by hand:** what the user should test on the device
- **Needs your attention:** questions, risks, or "none"
```

---

## 2026-10-17: Decompose canvas and toolbar widgets (ISSUE-019, ISSUE-020)
- **Before:** `WritingToolsToolbar` (526 lines) and `HandwritingCanvasWidget` (424 lines) mingled multi-axis layouts, gestures, eraser, ruler, and drawing state in monolithic stateful widgets.
- **After:** Extracted focused helpers (`WritingToolSelector`, `WritingToolSettings`, `WritingToolAppearanceControls`, `EraserSizeSelector`, `HandwritingCanvasInteractionController`, `RulerGestureController`, `HandwritingCanvasConfiguration`), reducing both widgets below 150 lines.
- **Why:** Resolve ISSUE-019 and ISSUE-020 to meet the project's code quality and maintenance standards.
- **Files changed:** `lib/features/canvas/presentation/widgets/writing_tools_toolbar.dart`, `lib/features/canvas/presentation/widgets/writing_tool_selector.dart`, `lib/features/canvas/presentation/widgets/writing_tool_settings.dart`, `lib/features/canvas/presentation/widgets/writing_tool_appearance_controls.dart`, `lib/features/canvas/presentation/widgets/eraser_size_selector.dart`, `lib/features/canvas/presentation/widgets/handwriting_canvas_widget.dart`, `lib/features/canvas/presentation/widgets/handwriting_canvas_interaction_controller.dart`, `lib/features/canvas/presentation/widgets/ruler_gesture_controller.dart`, `lib/features/canvas/presentation/widgets/handwriting_canvas_configuration.dart`, `context/current-issues.md`, `context/change-log.md`
- **Tests run:** `flutter analyze` passed (0 issues); `flutter test` passed (76/76 tests); `dart format` passed
- **Check by hand:** Test pen drawing, ruler manipulation, eraser dragging, and switching tool options on the toolbar.
- **Needs your attention:** none

## 2026-10-17: Add SharedPreferences restart persistence test (ISSUE-015)
- **Before:** Persistence was only tested against an in-memory adapter (`_MemoryNoteStorage`), leaving the real `SharedPreferencesNoteStorage` untested across restarts.
- **After:** An automated test verifies note saving, flushing, and reloading across fresh `SharedPreferencesNoteStorage` and `NoteRepository` instances.
- **Why:** Resolve ISSUE-015 to close the storage persistence test gap.
- **Files changed:** `test/note_persistence_test.dart`, `context/current-issues.md`, `context/progress-tracker.md`, `context/change-log.md`
- **Tests run:** `flutter test test/note_persistence_test.dart` passed; full `flutter test` passed (76/76 tests); `flutter analyze` passed (0 issues); `dart format` passed
- **Check by hand:** none; automated persistence test coverage added.
- **Needs your attention:** none

## 2026-10-17: Persist chosen accent color across restarts (ISSUE-004)
- **Before:** Chosen accent color reset to default whenever the app restarted.
- **After:** Chosen accent color is saved in `SharedPreferences` and restored on startup.
- **Why:** Resolve ISSUE-004 to preserve user accent preference.
- **Files changed:** `lib/core/theme/accent_color_storage.dart` (new), `lib/core/dependencies/app_dependencies.dart`, `lib/main.dart`, `test/accent_color_storage_test.dart` (new), `test/foundation_library_test.dart`, `context/current-issues.md`, `context/progress-tracker.md`, `context/change-log.md`
- **Tests run:** `flutter test test/accent_color_storage_test.dart test/foundation_library_test.dart` passed; full `flutter test` passed (75/75 tests); `flutter analyze` passed (0 issues); `dart format` passed
- **Check by hand:** Open the app, switch accent color via the palette in library, close and reopen the app to verify the selected accent remains active.
- **Needs your attention:** none

## 2026-10-17: Remove duplicate /note_editor route (ISSUE-013)
- **Before:** Both `/editor` and `/note_editor` were defined in `AppRoutes` and opened `NewNoteScreen`.
- **After:** `/note_editor` was removed, leaving `/editor` as the single route name.
- **Why:** Resolve ISSUE-013 to remove duplicate route alias.
- **Files changed:** `lib/core/routes/app_routes.dart`, `test/widget_test.dart`, `context/current-issues.md`, `context/change-log.md`
- **Tests run:** `flutter test test/widget_test.dart` passed; `flutter test` passed (72/72 tests); `flutter analyze` passed (0 issues); `dart format` passed (0 changed)
- **Check by hand:** Open the app and tap create note to confirm navigation to the editor works as expected.
- **Needs your attention:** none

## 2026-10-17: Clean up fixed issues section in current-issues.md
- **Before:** ISSUE-018 was marked `Status: Fixed` but listed under `## Open issues`, while `## Fixed issues` contained `*(none yet)*`.
- **After:** ISSUE-018 is moved under `## Fixed issues`, keeping `## Open issues` strictly for open issues.
- **Why:** Keep `current-issues.md` consistent with issue statuses.
- **Files changed:** `context/current-issues.md`, `context/change-log.md`
- **Tests run:** `flutter analyze` passed (0 issues); `flutter test` passed (71/71 tests passed)
- **Check by hand:** None; documentation and issue tracking update only.
- **Needs your attention:** `context/ai-workflow.md` referenced in `AGENTS.md` is named `ai-workflow-rules.md` in `context/`.

## 2026-10-17: Review project maintenance status
- **Before:** ISSUE-018 reported an unnecessary import that was already absent from the test file.
- **After:** ISSUE-018 is marked fixed; two large canvas UI files are recorded as review recommendations.
- **Why:** Align maintenance notes with the current code and checks.
- **Files changed:** `context/current-issues.md`, `context/change-log.md`
- **Tests run:** Not run; this was a read-only review. `flutter analyze` reported no issues, and `dart format --set-exit-if-changed lib test` found no formatting changes.
- **Check by hand:** None; no application behavior changed.
- **Needs your attention:** The `maintenance.md` filename was not present; review followed `context/feature-specs/maintenance standard.md`.

## 2026-10-17: Style page controls like the floating toolbar
- **Before:** The page filled the viewport under transparent right-side controls.
- **After:** The page remains full width, with the controls on a rounded surface panel matching the floating toolbar.
- **Why:** The user asked for the right-side control background to use the floating toolbar style.
- **Files changed:** `lib/core/theme/app_spacing.dart`, `lib/features/library/presentation/new_note_screen.dart`, `test/note_editor_redesign_test.dart`, `context/ui-context.md`, `context/change-log.md`
- **Tests run:** `flutter test test/note_editor_redesign_test.dart` passed; focused `flutter analyze` passed; format check passed
- **Check by hand:** Confirm the page extends behind the rounded control panel and the panel matches the floating toolbar.
- **Needs your attention:** none

## 2026-10-17: Add editor page control rail
- **Before:** Zoom, paper settings, and page navigation were inside the three-dots menu.
- **After:** The controls are visible in a scrollable rail beside the page, and the menu is removed.
- **Why:** Make common page actions available with one tap while preserving the drawing area.
- **Files changed:** `lib/core/theme/app_spacing.dart`, `lib/features/library/presentation/new_note_screen.dart`, `test/note_editor_redesign_test.dart`, `test/handwriting_canvas_test.dart`, `test/paper_template_engine_test.dart`, `test/foundation_library_test.dart`, `test/widget_test.dart`, `context/ui-context.md`, `context/current-issues.md`, `context/change-log.md`
- **Tests run:** `flutter test` passed; `flutter analyze` reported one existing info in untouched `test/ruler_geometry_test.dart`; focused analysis of changed Dart files passed; format check passed
- **Check by hand:** On a small portrait screen and in landscape, confirm the rail scrolls and does not cover the page or bottom toolbar. Try zoom, paper settings, and page navigation.
- **Needs your attention:** Full-project analysis reports one unrelated info in `test/ruler_geometry_test.dart` (recorded as ISSUE-018).

## 2026-10-16: Example entry (delete this when the first real entry is added)
- **Before:** Undo button stayed active even when there was nothing to undo.
- **After:** Undo button is disabled when the page history is empty.
- **Why:** Tapping it did nothing and confused the user.
- **Files changed:** `new_note_screen.dart`, `canvas_use_cases.dart`
- **Tests run:** `undo_redo_history_test.dart` passed
- **Check by hand:** Draw one stroke, undo it, and see that the button turns grey.
- **Needs your attention:** none
