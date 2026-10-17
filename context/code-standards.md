# Code Standards

The quality gate for PaperNote (Flutter / Dart). Every code change must pass this
file. General rules are in `ai-workflow.md` section 6. If the two disagree,
**this file wins**.

**Quality bar: high.** "It works" is not enough. Code is done only when it passes
every item in section 15 (Quality gate).

---

## 1. Commands

```
flutter pub get                          # install dependencies
dart format --set-exit-if-changed <files>  # check formatting of changed files
flutter analyze                          # static analysis: must show 0 issues
flutter test                             # whole suite
flutter test test/<file>_test.dart       # one test file
flutter test --coverage                  # coverage report (coverage/lcov.info)
```

Say exactly what you ran and the result. If you could not run something, say so.
Never write "tests pass" or "analysis is clean" without running them.

## 2. Lints, analysis, and formatting

- `analysis_options.yaml` is the source of truth. Read it and follow it.
- `flutter analyze` must report **0 errors, 0 warnings, 0 infos** on the code you
  touched. Do not leave new warnings.
- Follow Effective Dart: https://dart.dev/effective-dart
- Format with `dart format`. Format only the files you changed.
- Do not use `// ignore:` or `// ignore_for_file:` without asking the user.
  If the user approves, add a comment saying why.
- Do not lower lint strictness in `analysis_options.yaml` without asking.
- No `dynamic` unless unavoidable. No unnecessary `!` (bang) operators. No
  unnecessary casts. Prefer explicit types on public APIs.

## 3. Naming

| Thing | Style | Example |
|---|---|---|
| Files, folders, packages | `snake_case` | `note_page.dart` |
| Classes, enums, typedefs, extensions | `UpperCamelCase` | `NotePage`, `EraserSize` |
| Variables, functions, parameters, constants | `lowerCamelCase` | `currentPageIndex` |
| Private members | leading `_` | `_autosaveNote` |
| Booleans | read like a question | `isGridView`, `hasUndo`, `canRedo` |

- One main class per file, named after the file.
- Names say what a thing is or does. No `data`, `temp`, `x`, `tmp2`, `doStuff`.
- Event handlers: `_onXxx` (`_onCreateNote`). Use cases: verb first (`renameNote`).
- No abbreviations unless universal (`id`, `url`).

## 4. Project structure

- Feature-first: `lib/features/<feature>/{presentation,application,domain,data}`.
- Shared code only in `lib/core/`. Do not put feature logic in `core`.
- Screen widgets belong directly under `presentation/` and use a
  `<feature>_screen.dart` filename (for example, `home_screen.dart`).
- Reusable presentation widget classes belong in `presentation/widgets/`, with
  one widget per `<widget_name>.dart` file. Do not put reusable widgets in a
  screen file.
- `lib/main.dart` is the app entry-point exception; it may contain the root app
  widget.
- A new file goes in the layer it belongs to (see `architecture.md`).
- Keep the layer direction: UI -> use case / repository interface -> domain.
  Domain code never imports Flutter UI or plugins.
- No circular imports between features. If two features need the same thing,
  move it to `core` or to the owning feature's public API.
- Use package imports (`package:papernote/...`) inside `lib/`. No unused imports.
- **File size limits (strict):**
  - Normal code files (screens, widgets, use cases, services): target
    **100 to 300 lines**. Hard maximum **300 lines**.
  - There is **no minimum**. A short file (model, enum, constants, small helper)
    is fine. Never add code or merge unrelated code just to reach 100 lines.
  - Methods: about 40 lines or less. A `build` method: about 80 lines or less.
  - Test files: up to about 400 lines. Then split by topic.
  - Generated files: no limit. Never edit them by hand.
  - One file = one main job. If a file passes 300 lines, or a class does more than
    one job, split it into smaller files in the same layer.
  - This rule applies to **new and changed code**. If a file you must edit is
    already over 300 lines (for example `new_note_screen.dart`), do not make it
    bigger. Put new logic in a new file, and ask the user before any big split.

## 5. No hardcoded values (strict)

**Never write these inline in widgets or logic. Put them in a named constant,
theme token, or the right config:**

| Do not hardcode | Use instead |
|---|---|
| Colors (`Color(0xFF...)`, `Colors.red`) | Theme tokens / `ColorScheme` in `lib/core/theme/` |
| Text styles, font sizes, font names | `TextTheme` / theme tokens |
| Spacing, padding, radius, icon size, widths, heights | Named spacing/size constants in `lib/core/constants/` |
| Durations, animation curves, debounce times | Named constants |
| User-facing strings (labels, tooltips, messages) | One place (`AppConstants` or localization), not scattered in widgets |
| Route names | `AppRoutes` constants |
| Storage keys (`papernote.notes.v1`) | One named constant in the storage class |
| Default values (page size, pen width, opacity ranges, zoom limits 0.2-5x, slider min/max) | Named constants next to the model or tool that owns them |
| URLs, file extensions lists, MIME types | Named constants |
| Secrets, API keys, tokens, passwords | **Never in code or git.** Use environment/config outside the repo, and tell the user |

**Magic numbers:** a bare number with a meaning (`1.5`, `32`, `0.1`, `48`) must be
a named constant. Only `0`, `1`, `-1`, and `2` in obvious math may stay inline.

**Existing values:** before you add a constant, search for one that already
exists and reuse it. Do not create duplicates.

**Localization:** if a feature needs multiple languages, adding
`flutter_localizations` / `intl` is a new dependency. Ask the user first.

If you must keep a value inline, add a short comment saying why and tell the user.

## 6. Dart language quality

- **Null safety:** avoid `!`. Use null-aware operators, early returns, or handle the
  null case. Do not make a type nullable just to avoid initializing it.
- **Immutability:** `final` by default, `const` wherever possible.
- **Models:** immutable, `const` constructor, `copyWith`, and correct `==` /
  `hashCode` if compared. Never mutate a model or expose a mutable list. Create a
  new list when you change it.
- **Collections:** use collection `if`/`for`, spread, and `whereType` instead of
  manual loops when clearer.
- **Enums:** use enums or sealed types instead of strings or ints for fixed sets.
- **Functions:** one job, short, few parameters. Prefer named parameters when there
  are more than two. Use early returns instead of deep nesting.
- **No** global mutable state, no singletons that hide dependencies.
- **Async:** use `async`/`await`. Never ignore a `Future` (await it or mark it with
  `unawaited` and a reason). Do not use `async` when there is no `await`.
- **Errors:** catch specific exceptions. Never swallow errors silently. No empty
  `catch`. Show the user a clear message, and keep the app in a safe state.
- **Doc comments:** `///` on public classes and non-obvious public methods. Explain
  WHY. Do not comment obvious code.

## 7. Flutter widget quality

- `const` constructors and `const` widgets wherever possible.
- Keep `build` small and pure. No heavy work, no network/file/storage calls, no
  creating controllers inside `build`.
- Extract reusable or stateful UI into **widget classes**, not helper methods that
  return widgets.
- Use `StatelessWidget` unless you need state. Keep state as low as possible.
- Give a `Key` to items in dynamic lists. Use `ListView.builder` / `GridView.builder`
  for long lists.
- **Dispose** every controller, focus node, animation controller, stream
  subscription, recorder, and player in `dispose()`.
- Do not use `BuildContext` after an `await` without checking `mounted`.
- Do not call `setState` after dispose.
- Avoid rebuilding large trees: split widgets and use `const`.
- Use `Theme.of(context)`, `ColorScheme`, and `TextTheme`. Light and dark mode must
  both look correct.
- Layout must work on small phones, tablets, landscape, and desktop widths.
  Avoid fixed sizes that overflow. Use `LayoutBuilder`, `Flexible`, `Expanded`,
  `MediaQuery` where needed. No overflow warnings.
- Prefer composition over inheritance.

## 8. Performance

- Do not do expensive work in `build`, in `paint`, or on every pointer event.
- `CustomPainter.shouldRepaint` must return `true` only when something changed.
  Use `RepaintBoundary` around the canvas and paper layers when it helps.
- Do not rebuild or re-encode the whole note on every pointer move. Save at
  meaningful points (stroke end, text change), as the current design does.
- Do not hold large lists or images needlessly in memory.
- Heavy computation should not block the UI thread.
- Measure before you optimize. Do not add "clever" optimizations without a reason.

## 9. Accessibility and UX

- Every icon-only button has a `tooltip` or `Semantics` label.
- Touch targets are at least 48x48 logical pixels.
- Text and icons have enough contrast in light and dark themes.
- Text must scale with the system text size without breaking the layout.
- Disabled states are visible (for example undo/redo when history is empty).
- Show feedback for errors and long actions (snackbar, dialog, progress).
- Destructive actions (delete) need a confirmation.

## 10. State, dependencies, and plugins

- Pass `NotesRepository`, `NoteStorage`, and use cases through constructors
  (optional parameters defaulting to `AppDependencies`) so tests can inject fakes.
- Do not add global mutable state.
- Plugin calls (`image_picker`, `file_picker`, `record`, `audioplayers`,
  `speech_to_text`, `url_launcher`, `path_provider`) must not be added to
  `NewNoteScreen`. Put them behind a service.
- Always handle plugin failure and permission denial, and show a message.
- Do not add, remove, or upgrade a package without asking. Check that a package is
  maintained and supports all target platforms before you propose it.
- `pubspec.lock` is committed (this is an app).

## 11. Persistence standards

When you add or change a field on a note, page, stroke, tool, paper, or text
model, in the same change:

1. update `NoteModelMapper` (to and from the map),
2. update `NoteSnapshotCodec` if the shape changes,
3. update `test/note_persistence_test.dart` so the field round-trips.

Also:
- Old saved notes must still load. Give new fields a safe default when the key is
  missing in old data.
- Do not change the key `papernote.notes.v1` or break the snapshot format without
  asking the user first.
- Never write to storage from a widget. Go through use case -> repository -> storage.
- Never log or print note content.

## 12. Security and privacy

- No secrets, keys, tokens, or passwords in code, tests, or git.
- Validate input: link addresses, file names, picked files, text.
- Do not execute or open anything from user data without validation.
- Request only the permissions the feature needs. Do not add new permissions
  without asking.
- Notes are private, local data. Do not send them anywhere.
- Do not log personal data.

## 13. Git hygiene and `.gitignore`

**Check `.gitignore` before you add, create, or commit files.** If a file that
should be ignored is not ignored (or a needed file is ignored), tell the user.
Changing `.gitignore` is a configuration change, so ask first.

**Must be ignored (never committed):**

```
# Dart / Flutter generated
.dart_tool/
.packages
.pub-cache/
.pub/
build/
.flutter-plugins
.flutter-plugins-dependencies
coverage/
*.log

# IDE / OS
.idea/
*.iml
*.ipr
*.iws
.vscode/*        # keep shared settings only if the team wants them
.DS_Store
Thumbs.db

# Android
android/.gradle/
android/local.properties
android/app/debug/
android/app/profile/
android/app/release/
android/key.properties
*.jks
*.keystore
android/**/GeneratedPluginRegistrant.*

# iOS / macOS
ios/Pods/
ios/.symlinks/
ios/Flutter/Generated.xcconfig
ios/Flutter/ephemeral/
ios/Flutter/flutter_export_environment.sh
macos/Pods/
macos/Flutter/ephemeral/
**/xcuserdata/
*.mode1v3
*.mode2v3
*.pbxuser

# Windows / Linux
windows/flutter/ephemeral/
linux/flutter/ephemeral/

# Secrets and local config
.env
.env.*
*.pem
*.p12
secrets.*
```

**Must be committed (never ignored):**
`pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `lib/`, `test/`,
platform project files (`android/`, `ios/`, ... except the generated ones above),
`AGENTS.md`, `GEMINI.md`, and the `context/` folder.

Rules:
- Never commit build output, generated files, local machine paths, keys, or
  keystores.
- Do not commit large binary files without asking.
- Keep commits focused: one purpose per commit, a clear message that says what
  and why. Do not mix unrelated changes.
- Do not commit commented-out code or debug prints.

## 14. Testing standards (must test)

**Core rule: every change must be tested.**

- Every behavior change needs a new or updated test in the same change.
- Every bug fix needs a test that fails before the fix and passes after.
- New logic (use cases, services, mappers, geometry) needs **unit tests**.
- New or changed UI behavior needs **widget tests**.
- Test normal cases, edge cases (empty, null, minimum, maximum), and error cases.
- Write tests first for new roadmap capabilities.

**Test quality**
- Deterministic: no real storage, real time, randomness, or network. Inject
  `NotesRepository` / `NoteStorage` (in-memory) and fakes for plugins.
- Independent: tests do not depend on order or share state.
- Clear names that say the behavior: `'undo is disabled when history is empty'`.
- One reason to fail per test. Arrange, Act, Assert.
- No `sleep`/arbitrary delays. Use `pumpAndSettle` / `pump` with clear intent.
- Do not test implementation details. Test behavior.
- Never delete, skip, or weaken a test to make it pass. A test may be removed only
  if proven obsolete, flaky by design, or superseded with equal coverage, and only
  after asking the user.
- Keep test file names `<topic>_test.dart` in `test/`.

**Coverage**
- Run `flutter test --coverage` for larger changes. Every new or changed branch
  should be covered by a test. Tell the user which new lines are not covered.
- (Ask the user if they want a numeric coverage threshold. None is set yet.)

**Must-run regression set** (for changes touching the main value path)
`foundation_library_test`, `widget_test`, `note_management_search_test`,
`note_persistence_test`, `handwriting_canvas_test`, `digital_writing_tools_test`,
`undo_redo_history_test`, `paper_template_engine_test`, `note_editor_redesign_test`.

**Which test to run for which change**

| You changed | Run first | Then also |
|---|---|---|
| App launch, accent, library screen | `foundation_library_test.dart` | `widget_test.dart`, `empty_library_view_test.dart` |
| Empty library state | `empty_library_view_test.dart` | `foundation_library_test.dart` |
| Create / open / rename / delete / search | `note_management_search_test.dart` | `foundation_library_test.dart` |
| Models, mapper, codec, storage | `note_persistence_test.dart` | `note_editor_redesign_test.dart` |
| Canvas input, drawing, erasing, tools | `handwriting_canvas_test.dart`, `digital_writing_tools_test.dart` | `undo_redo_history_test.dart` |
| Undo / redo / history | `undo_redo_history_test.dart` | `handwriting_canvas_test.dart` |
| Ruler | `ruler_geometry_test.dart` | `note_editor_redesign_test.dart` |
| Paper pattern / color / orientation | `paper_template_engine_test.dart` | `note_persistence_test.dart` |
| Editor screen, text, selection, popovers, layout | `note_editor_redesign_test.dart` | tests of the related feature |

When a change crosses features: focused test first, then adjacent integration
tests, then `flutter analyze`. Before finishing a big change, run the whole
`flutter test`.

**Known test gaps** (no automated test exists today)
- Image/file picking, microphone recording and permission denial, speech
  dictation, opening links, file cleanup.
- Real SharedPreferences restart persistence.
- Attachment restoration/rendering, link/file edge cases, persistence errors.

Do not claim these flows are verified. Tell the user to test them by hand on a
real device, and propose plugin fakes or integration tests.

## 15. Quality gate (must all pass before a task is done)

- [ ] `dart format` shows no changes needed on touched files
- [ ] `flutter analyze` shows 0 issues on touched code
- [ ] No hardcoded colors, sizes, strings, keys, routes, durations, or magic numbers
- [ ] No secrets, no debug prints, no commented-out code, no own TODOs
- [ ] Names, structure, and layers follow sections 3 and 4
- [ ] No file you created or changed is over 300 lines (and none grew past it)
- [ ] Models are immutable and every new field is serialized and tested
- [ ] Controllers and resources are disposed; `mounted` is checked after `await`
- [ ] Errors are handled and shown to the user; nothing fails silently
- [ ] Light and dark themes, small and large screens, and accessibility checked
- [ ] New or changed behavior has tests; related tests and (for big changes) the
      full suite pass
- [ ] `.gitignore` checked; no generated or secret files added
- [ ] No unrelated files changed
- [ ] `context/change-log.md` has an entry, and related context files are updated

If any item fails, the task is **not done**. Fix it, or tell the user clearly what
is missing and why.

## 16. Do not

- Do not claim a roadmap feature is done until you checked source and tests.
  `docs/*_GITHUB_ISSUES.md` is backlog, not proof.
- Do not change unrelated files or reformat untouched code.
- Do not add a package, permission, or platform change without asking.
- Do not lower quality to finish faster. Ask the user instead.
