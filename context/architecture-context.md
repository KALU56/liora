# Architecture

How PaperNote is built and how the parts relate. The code is the source of
truth. If this file and the code disagree, tell the user and update this file.

## 1. Overview

PaperNote is a local-first Flutter app. It uses a feature-oriented, layered
structure. Notes and new attachment blobs are stored in SQLite. The old
SharedPreferences note snapshot is migrated on first read. There is no server,
account, or cloud.

```text
main.dart
  ├─ AppDependencies (composition root)
  ├─ AppRoutes
  └─ PaperNoteApp (theme + accent scope)
       ├─ Library presentation ── NotesUseCases ── NotesRepository interface
       └─ Editor presentation ───┬─ NotesUseCases ─ NoteRepository
                                 ├─ PaperUseCases / PaperTemplate
                                 └─ CanvasUseCases / page-local history + eraser

NoteRepository ─ NoteSnapshotCodec ─ NoteModelMapper ─ SqliteNoteStorage
                                                     └─ NoteDatabase
NoteAttachmentStorage ────────────────────────────────┘
```

## 2. Layers

| Layer | Owns | Must NOT |
|---|---|---|
| **Presentation** | Screens, dialogs, toolbars, painters, transient UI state. Turns taps and pointer events into model changes and renders models. | Contain business rules or talk to storage directly. |
| **Application** | Small use-case facades: `NotesUseCases`, `PaperUseCases`, `CanvasUseCases`. Sit between UI and domain/data. | Contain UI code. |
| **Domain** | Note, page, text, paper, tool, stroke, point, and history concepts. | Depend on Flutter UI or platform storage. |
| **Data** | Note persistence, JSON mapping, the storage boundary. | Contain UI code. |
| **Core** | App-wide routing, dependency composition, theme, value objects, constants, reusable controls. | Contain feature logic. |

Dependency flow: UI -> use case / repository abstraction -> domain objects.
Concrete storage is assembled in one place (`AppDependencies`).

## 3. Repository map

| Path | Role |
|---|---|
| `lib/main.dart` | Entry point, initialization, app root, theme, routes, accent scope. |
| `lib/core/` | Composition root, routes, theme tokens, value objects, constants, shared controls. |
| `lib/features/library/` | Library screen and empty-library widget. |
| `lib/features/editor/` | Editor screen and focused part files, plus injectable media service. |
| `lib/features/notes/` | Note/page/text models, repository contract and implementation, persistence/storage, mapping, dialogs, note cards. |
| `lib/features/canvas/` | Tool/stroke/point/action models, handwriting widget and rendering, ruler geometry, erasing, history. |
| `lib/features/paper/` | Paper template model, paper use case, background rendering, customization sheet, UI metadata. |
| `test/` | Automated Flutter tests. |
| `docs/` | Roadmap/issue plans. NOT proof that a feature exists. |
| `android/ ios/ macos/ windows/ linux/ web/` | Platform runner projects and configuration. |

## 4. Data model and relationships

- `NoteModel` owns an ordered list of `NotePage` values and document metadata
  (ID, title, page count, timestamps, and trash state).
- `NotePage` owns its `PaperTemplate`, `Stroke`s, active `ToolConfig`,
  `NoteTextBlock`s, and attachment references.
- `Stroke` owns sampled `TouchPoint`s and the tool properties needed to render it.
- `ToolConfig` is the current drawing tool. Its values are **copied** into each
  stroke when drawn, so changing the tool never restyles old strokes.
- `PaperTemplate` defines orientation, size, color, and pattern geometry. Paper
  and handwriting share page coordinates and are zoomed together by the editor.
- `CanvasHistoryManager` stores inverse-capable `CanvasAction`s. The editor
  caches one `CanvasUseCases` per page ID, so history is page-local.
- `NotesRepository` is the contract used by screens and use cases.
  `NoteRepository` is the in-memory implementation backed by a `NoteStorage`.
- All model values are **immutable**. An edit creates a new value (`copyWith`)
  and replaces the old one.
- Attachments are stored as string references in page data. New attachment bytes
  live in `stored_attachments` in the same SQLite database. Existing path
  references remain readable for compatibility and are not yet migrated.

## 5. Persistence

- `NoteRepository` updates its in-memory list immediately, then queues writes for
  individual notes.
- Writes go through a future queue so an older write cannot overwrite newer
  state for the same note.
- `NoteModelMapper` converts notes/pages/strokes/tools/paper/text to JSON-compatible
  maps. `NoteSnapshotCodec` encodes and decodes the full snapshot.
- `SqliteNoteStorage` stores notes in `stored_notes`, ordered by `sort_order`.
- On first read, `SqliteNoteStorage` transactionally migrates the old value under
  `papernote.notes.v1` and removes it only after successful insertion.
- Malformed snapshots are ignored at startup so the app can still launch.
- `flush()` lets the editor wait for pending writes when the user leaves.
- `NoteStorage` is the test seam. Tests can use an in-memory adapter.

Editor page, mode, selection, and voice-session state are grouped in
`EditorSessionState`; `NewNoteScreen` remains the widget coordinator.

## 6. Main flows

**App startup**
```text
main() -> ensureInitialized -> appDependencies.initialize()
  -> appNoteRepository.initialize() -> SqliteNoteStorage.readNotes()
  -> NoteSnapshotCodec.decodeNote() per database row
  -> runApp(PaperNoteApp)
```
Routes: `/` -> `HomeScreen`; `/editor` -> `NewNoteScreen`. The legacy library editor path re-exports the editor for compatibility.

**Create / open a note**
- Create: `HomeScreen._onCreateNote` -> `/editor` -> `NewNoteScreen` creates the
  note with a default page through `NotesUseCases.createNote`, then auto-saves.
- Open: `HomeScreen._onOpenNote` passes the `NoteModel` as route arguments. The
  editor copies its pages into local state and starts at page 0.
- Rename / trash / restore / permanent delete / content search go through `NotesUseCases`; the repository queues per-note SQLite writes. Search covers titles, page text, and attachment references.
- Trash state is persisted additively; old note snapshots default to not trashed.

**Pointer to saved stroke**
```text
HandwritingCanvasWidget pointer events
 -> map viewport position to page coordinates
 -> collect TouchPoints using the page ToolConfig
 -> build the Stroke -> onStrokesChanged / onActionRecorded
 -> NewNoteScreen._replaceCurrentPage -> _autosaveNote
 -> NotesUseCases.updateNote -> NoteRepository -> per-note SQLite write queue
```
The canvas widget handles pointer and render mechanics. The editor owns the
current page and the save callback. `CanvasUseCases` uses `CanvasHistoryManager`
for undo/redo and `EraserService` for erasing.

**Typed text**
Text mode -> tap page -> inline text field at page coordinates -> `_updateCanvasText`
-> create or replace a `NoteTextBlock` in the page -> `_replaceCurrentPage` -> auto-save.

**Paper change**
Paper settings -> `PaperCustomizationSheet` -> `PaperUseCases.updateTemplate`
-> `NotePage.copyWith(paperTemplate: ...)` -> `_replaceCurrentPage` -> auto-save.

**Attachments and audio**
`NoteAttachmentStorage` and `EditorMediaService` wrap platform operations. Picked files are stored as SQLite blobs and referenced as `attachment:<id>` in `NotePage.attachments`. On read, readable legacy filesystem references are copied into the database and note rows are updated; missing or unreadable paths remain as references and show a fallback. Permanent deletion removes a blob only when no remaining note references it.

## 7. Where to look (code ownership)

| Behavior | Main files |
|---|---|
| Launch, theme, accent | `lib/main.dart`, `lib/core/theme/*`, `lib/core/dependencies/app_dependencies.dart` |
| Navigation | `lib/core/routes/app_routes.dart` |
| Library screen and cards | `lib/features/library/presentation/home_screen.dart`, `.../widgets/empty_library_view.dart`, `lib/features/notes/presentation/widgets/note_card.dart`, `note_page_thumbnail.dart` |
| Editor coordination and UI | `lib/features/editor/presentation/new_note_screen.dart` and its `editor_*.dart` part files |
| Media plugins and attachment operations | `lib/features/editor/data/editor_media_service.dart`, `lib/features/notes/data/note_attachment_storage.dart` |
| Note operations | `lib/features/notes/application/notes_use_cases.dart`, `.../domain/repositories/notes_repository.dart`, `.../data/repositories/note_repository.dart` |
| Serialization | `.../data/mappers/note_model_mapper.dart`, `note_snapshot_codec.dart`, `.../data/repositories/note_storage.dart` |
| Note, page, text models | `.../domain/models/note_model.dart`, `note_page.dart`, `note_text_block.dart` |
| Canvas input and rendering | `lib/features/canvas/presentation/widgets/handwriting_canvas_widget.dart`, `stroke_painter.dart`, `stroke_path_builder.dart` |
| Tools, strokes, history | `lib/features/canvas/domain/models/*`, `.../application/canvas_use_cases.dart`, `.../domain/services/*` |
| Ruler math | `lib/features/canvas/presentation/widgets/ruler_geometry.dart` |
| Paper | `lib/features/paper/domain/models/paper_template.dart`, `.../presentation/widgets/*`, `.../application/paper_use_cases.dart` |

## 8. Architecture rules for this project

1. **Page isolation.** Strokes, text, attachments, and canvas history of one page
   must never mix with another page.
2. **Serialize every field.** If you add or change a field in a note, page,
   stroke, tool, paper, or text model, you must also update `NoteModelMapper`,
   the codec if needed, and `test/note_persistence_test.dart`.
3. **Keep models immutable.** Use `copyWith`. Do not mutate a model in place.
4. **Keep the layer direction.** UI -> use case / repository interface -> domain.
   Do not call storage or plugins from domain code.
5. **Do not add more plugin calls or large logic to `NewNoteScreen`.** Put new
   logic in a use case, controller, or service.
6. **Inject dependencies.** Use `NotesRepository` / `NoteStorage` through
   constructors so tests stay deterministic. Do not create hidden global state.
7. **Tool values are copied into strokes.** Do not make strokes read the live
   tool config when rendering.
8. **Ask the user first** before changing the `papernote.notes.v1` format or key.
   Old saved notes could stop loading. The approved migration keeps this key as
   a one-time source until the database transaction succeeds.

## 9. Known limitations

- `NewNoteScreen` is a stateful coordinator. Its screen and UI methods are split into focused files and plugin operations are injected services, but shared transient state remains in the coordinator.
- Old notes in SharedPreferences are migrated to individual SQLite rows; an interrupted migration retains the source snapshot.
- New attachments are SQLite blobs and missing blobs show an unavailable state. Existing filesystem path references still need migration for full portability.
- Undo/redo covers drawing actions only, including stroke restyling; text edits are excluded and the controls say so.
- The editor lives in `features/editor/`, with shared transient state coordinated by `NewNoteScreen`.
- Media behavior still needs real device checks for target OS permissions and plugin support.
