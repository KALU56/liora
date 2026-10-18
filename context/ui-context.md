# UI Context

Every screen and control in PaperNote, what the user does, and what the code does.
**The code is the source of truth.** If this file and the code disagree, tell the
user and update this file.

Reference images are in `context/screenshots/`. Look at them before you change how
a screen looks. Labels may appear as tooltips, menu text, or dialog headings
depending on screen size.

## 1. Screens and navigation

| Route | Screen | File |
|---|---|---|
| `/` | `HomeScreen` (library) | `lib/features/library/presentation/home_screen.dart` |
| `/editor` | `NewNoteScreen` | `lib/features/editor/presentation/new_note_screen.dart` |

Library -> editor: create button (new note) or tapping a note card (existing note,
passed as route arguments). Editor -> library: Back button. The old library screen path
re-exports the editor for compatibility.

## 2. Library screen

| Control | User action | Code path and result |
|---|---|---|
| **PaperNote header** | Shows the app name and a subtitle | `HomeScreen.build` reads `AppConstants.appName` |
| **Accent palette** | Opens "Choose an accent". Picking a swatch changes the theme accent | `_showAccentPicker` -> `AccentColorScope.onAccentChanged` -> `PaperNoteApp.setState`. saved across restarts |
| **Search** | Opens a search field. Typing filters notes. Closing clears the query | `onChanged` updates `_searchQuery` -> case-insensitive search across titles, page text, and attachment references |
| **List/grid toggle** | Switches note cards between list and two-column grid | `_isGridView` is local state. Grid cards render first-page paper, strokes, and text |
| **Create button / empty-state create button** | Opens the editor with a new note | `_onCreateNote` -> `/editor`. The editor creates a note with a default page and title |
| **Note card** | Opens that note | `_onOpenNote` passes the `NoteModel` as route arguments |
| **Card menu -> Rename** | Rename dialog. Blank input becomes `Untitled Note` | `_onRenameNote` -> `NotesUseCases.renameNote` -> repository updates title and date, queues save |
| **Card menu -> Delete** | Confirmation dialog. Confirm moves the note to trash, cancel keeps it in the library | `_onDeleteNote` -> moves the note to trash. Trash view supports restore and confirmed permanent delete |
| **Empty library state** | Says there are no notebooks and offers a create action | `EmptyLibraryView` calls the callback from `HomeScreen` |
| **No-matches message** | Shown when notes exist but the content query matches none | Derived from `searchNotes`. Does not change stored notes |

Note cards show title, page count, relative modification time, and in grid view a first-page preview. After returning from the editor, the library rebuilds from repository data.

## 3. Editor top bar, pages, and canvas

| Control | User action | Code path and result |
|---|---|---|
| **Back** | Saves, waits for queued writes, returns to the library | `_leaveEditor` -> `_autosaveNote` -> `NotesUseCases.flush` -> `Navigator.pop` |
| **Note title** | Opens a title dialog. Done saves the trimmed title, Cancel restores the old one | `_editTitle` updates `_titleController`, calls `_autosaveNote` |
| **Undo** | Reverses the latest canvas action. Disabled when there is none | `_undoStroke` -> page-local `CanvasUseCases.undo` -> `CanvasHistoryManager.undo` -> replace page strokes, auto-save. Canvas history only, not text history; tooltips say drawing action |
| **Redo** | Reapplies the latest undone action. Disabled when none | `_redoStroke` -> `CanvasUseCases.redo` |
| **Add page (+)** | Adds a page that copies the current paper template, selects it, resets zoom, saves | `_addPage` -> `_newPage(template: current.paperTemplate)` -> `_autosaveNote` |
| **Page control rail** | Always-visible vertical controls over the page's right edge: Zoom in, Zoom out, Reset zoom, Paper settings (custom paper SVG), Previous page, Next page. The page fills the viewport beneath a surface panel styled like the floating toolbar, and the rail scrolls when vertical space is short. Previous/next are disabled at the first/last page | `page_control_rail` -> `_zoomIn` / `_zoomOut` / `_resetZoom` / `_openPaperCustomization` / `_goToPage` |
| **Page counter** | Shows "Page N of M". Informational, not a picker | From `_currentPageIndex` and `_pages.length` |
| **Pinch zoom** | Pinch scales the page from 0.2x to 5x | `InteractiveViewer` scaling on. Drag panning is available through the Pan mode button; while active, canvas drawing is disabled |
| **Paper settings** | Opens the paper sheet. Updates this page's paper and saves | `_openPaperCustomization` -> `PaperCustomizationSheet.show` -> `PaperUseCases.updateTemplate` -> `_replaceCurrentPage` |

## 4. Floating editor toolbar

| Control | What it does |
|---|---|
| **Tt / Type on canvas** | Enters text mode. Tap an empty spot to create a text block, or tap existing text to edit. Typing updates the page and auto-saves. Tapping again exits text mode |
| **Microphone / Voice input** | Starts or stops speech recognition. Creates or updates a text block with recognized words. Partial results are shown, final segments are collected. Needs speech plugin and platform support. Errors show a snackbar. This is dictation, **not** audio recording |
| **Add content (+)** | Opens a popover: Add photo, Add file, Add link |
| **Handwriting / drawing** | Toggles drawing mode and closes text editing and popovers. Pointer input then makes strokes |
| **Pan page** | Toggles page drag mode; drawing input is disabled until pan mode is turned off |
| **Pen settings** | Turns on drawing and toggles a settings popover with color, width, and opacity controls for the selected drawing tool; for Eraser, it shows the eraser size control |
| **More tools (circle arrow) / Back (left arrow)** | Toggles the toolbar between normal mode and tools mode. In tools mode, Pen, Pencil, Highlighter, Eraser, Shapes, Ruler, Record audio / Stop audio recording, and Clear handwriting replace the normal controls. Shapes opens a nested row with each shape type and the fill toggle. Back from that row returns to tools mode; Back again returns to normal mode. Selecting tools, recording, and clearing handwriting keep the current mode open. The toolbar scrolls horizontally when a row is wider than the screen. |

### Add content popover

| Item | Behavior |
|---|---|
| **Add photo** | Gallery picker. Copies the image to the app documents folder, stores the copied path, shows recognized image formats inline. Picker or copy errors show a snackbar |
| **Add file** | System file picker (first selected file). Copies it to app documents, stores the path, shows a file row. Audio files get a Play button. Other types are listed and can be opened with another app |
| **Add link** | Entry dialog. A missing scheme becomes `https://`, the address is validated, then stored as `url:<address>`. The page shows a link row. Tapping calls `url_launcher`. Invalid or unopenable links show an error snackbar |
| **Nothing selected** | Cancels with no change |

### Tools mode actions

| Item | Behavior |
|---|---|
| **Record audio / Stop** | Checks microphone permission, records M4A in app documents. On Stop, copies it to a kept path and adds it to page attachments. An audio row can be played with `audioplayers`. No timestamp sync and no waveform |
| **Clear handwriting** | Clears only the current page's strokes and records a clear action for undo. Does not clear text or attachments |

## 5. Pen settings and tool controls

Choosing a tool in toolbar tools mode updates the current page's `ToolConfig`,
turns on drawing mode, keeps tools mode open, and saves the note. Pen settings
does not switch tools; it only adjusts the selected tool. Pen, Pencil,
Highlighter, Eraser, and Shapes use SVG assets from `assets/icons/` in tools
mode. They inherit the current icon theme color for selected and unselected
states. Shape type and fill are controlled in the nested Shape toolbar row.

| Control | Behavior |
|---|---|
| **Pen / Pencil / Highlighter** | Choosing a different one loads its default color, width, and opacity. Choosing the already active one keeps its current settings |
| **Color swatches** | Black, blue, red, green, yellow. Update the active page tool color |
| **Width slider** | Stroke width 1 to 32 logical units |
| **Opacity slider** | 0.1 to 1.0 |
| **Eraser size** | Small or Large (radius from `EraserSize`). Moving the pointer erases intersecting strokes |
| **Shape type** | In the Shape toolbar row: Line, rectangle, square, oval, circle, triangle, arrow. Dragging creates a shape stroke |
| **Fill shape** | In the Shape toolbar row: toggles filled rendering for supported shapes |
| **Ruler** | A movable, rotatable overlay. Drawing against its edge makes a straight stroke. Dismissing it switches the tool back to pen |

Tool values are **copied into each new stroke**. Changing the tool never restyles
earlier strokes.

## 6. Text and selected-stroke popovers

**Text style** (tap existing text):
- Size slider 12 to 48
- Font menu: Roboto, serif, monospace
- Bold and Italic toggles
- Color swatches
- Dragging a text block moves it, clamped to the page bounds
- Typing, style, and position changes update the page and are saved

**Stroke style** (tap a stroke while in drawing mode):
- Selects the stroke and opens controls
- Color, width (1 to 32), opacity (0.1 to 1.0)
- Fill toggle for filled shapes
- These edits are saved and included in drawing-only undo/redo

## 7. Paper settings sheet

Opened from the page control rail -> Paper settings. The user picks pattern (blank, ruled,
grid, dotted), background color, orientation, and spacing. Live updates and the
final result return a `PaperTemplate` that replaces the current page's template
and is saved. The paper is painted behind the handwriting and text layer. Both
use the same page coordinates inside one zoomable viewer.

## 8. Rules for UI changes

1. Look at `context/screenshots/` and the current screen before you change it.
2. Do not hardcode colors, sizes, or strings. Use theme tokens and constants
   (see `code-standards.md` section 5).
3. Keep light and dark themes, small and large screens, and landscape working.
4. Every icon-only button needs a tooltip or semantic label.
5. Keep disabled states visible (undo and redo with empty history).
6. Keep touch targets at least 48x48.
7. Destructive actions need a confirmation.
8. If you add, remove, or change a control, update this file and add a test
   (`note_editor_redesign_test.dart` for editor, `foundation_library_test.dart`
   or `note_management_search_test.dart` for the library).
9. Do not put new plugin calls or large logic in `NewNoteScreen`. Use a service.
10. If a control is named in this file but you cannot find it in the code, tell
    the user.

## 9. Which test covers which UI action

| User action | Primary tests |
|---|---|
| Open app, see empty library, create note | `foundation_library_test`, `empty_library_view_test`, `widget_test` |
| Search, open, rename, trash, restore | `note_management_search_test` |
| Edit and reopen note data | `note_persistence_test`, `note_editor_redesign_test` |
| Draw, clear canvas, erase | `handwriting_canvas_test`, `digital_writing_tools_test` |
| Switch pen/pencil/highlighter/shape settings | `digital_writing_tools_test`, `note_editor_redesign_test` |
| Undo and redo | `undo_redo_history_test` |
| Ruler | `ruler_geometry_test`, `note_editor_redesign_test` |
| Paper pattern, color, orientation | `paper_template_engine_test` |
| Text style, selected stroke, narrow layout, popovers | `note_editor_redesign_test` |
| Pick files/images, record, dictate | `editor_media_flow_test` uses plugin service fakes; real plugin behavior still needs device checks |
