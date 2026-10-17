# Change Log

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
