# Progress Tracker

The status of every feature. Update this file when a feature's status changes.
**The code is the source of truth.** Do not mark a feature "Done" until you have
checked the source and the tests.

## Status meanings

| Status | Meaning |
|---|---|
| Done | Works in the code, has automated tests, nothing important missing |
| Done (needs device test) | Works in the code, but depends on plugins or permissions. No automated test, so it must be tested by hand on a real device |
| Partial | Some of it exists. The full workflow is missing |
| Planned | In the roadmap only. Not in the code |
| Blocked | Cannot continue. See the note |

*This first version was written from the project guide, not from a fresh code
check. Anyone who works on a feature should verify its row against the code.*

## 1. Current features

| Feature | Status | Tests | Notes |
|---|---|---|---|
| Library: empty state, create, open | Done | `foundation_library_test`, `empty_library_view_test`, `widget_test` | |
| Library: rename, trash, restore, permanent delete | Done | `note_management_search_test`, `note_persistence_test` | Permanent delete cleans up unreferenced local attachments |
| Library: content search | Done | `note_management_search_test` | Searches titles, page text, and attachment references |
| Library: list/grid view | Done | `foundation_library_test`, `editor_navigation_test` | Grid preview renders first-page paper, strokes, and text |
| Accent color picker | Done | `foundation_library_test`, `accent_color_storage_test` | Persisted via SharedPreferences |
| Light and dark theme (system) | Done | `foundation_library_test` | |
| Note lifecycle and auto-save | Done | `note_persistence_test`, `note_editor_redesign_test` | |
| Floating toolbar mode switching | Done | `note_editor_redesign_test`, `digital_writing_tools_test`, `editor_media_flow_test` | Shape options open as a nested row; Back moves between shape, tools, and normal modes |
| Multiple pages: add, next, previous | Partial | `note_persistence_test` | No reorder, thumbnails, or delete page |
| Paper: blank, ruled, grid, dotted, color, orientation, spacing | Done | `paper_template_engine_test` | |
| Handwriting: pen, pencil, highlighter | Done | `handwriting_canvas_test`, `digital_writing_tools_test` | |
| Eraser | Done | `digital_writing_tools_test` | Removes whole intersecting strokes |
| Shapes and fill | Done | `digital_writing_tools_test`, `note_editor_redesign_test` | No shape recognition |
| Ruler | Done | `ruler_geometry_test`, `note_editor_redesign_test` | |
| Undo and redo | Partial | `undo_redo_history_test` | Drawing actions, including stroke restyling. Not text; controls say drawing-only |
| Typed text blocks, style, drag | Done | `note_editor_redesign_test` | No rich lists |
| Select and restyle strokes and text | Done | `note_editor_redesign_test` | Single selection only |
| Zoom and pan | Done | `note_editor_redesign_test`, `editor_navigation_test` | Pan mode enables drag while disabling drawing |
| Local persistence (SQLite with attachment migration) | Done | `note_persistence_test`, `note_attachment_storage_test` | Old note snapshots and existing attachment paths migrate on first read |
| Add photo | Done (needs device test) | `editor_media_flow_test` | Fake-driven flow; real plugin and permissions need device checks |
| Add file | Done (needs device test) | `editor_media_flow_test` | Non-audio files can be opened in another app; real plugin needs device check |
| Add link | Done (needs device test) | none | |
| Audio recording | Done (needs device test) | `editor_media_flow_test` | Fake-driven flow; microphone permission needs device check |
| Audio playback (basic) | Done (needs device test) | none | No timestamp sync, no waveform |
| Speech-to-text dictation | Done (needs device test) | `editor_media_flow_test` | Fake-driven result; platform speech support needs device check |

## 2. Roadmap (not built)

| Feature | Status | Notes |
|---|---|---|
| PDF import, viewing, search, export | Planned | |
| Folders and favorites | Planned | |
| Trash and recovery | Done | `note_management_search_test`, `note_persistence_test` |
| Global content search (page text, attachments) | Done | `note_management_search_test` |
| Clipboard, lasso, group selection | Planned | |
| Shape recognition | Planned | |
| Rich list formatting | Planned | |
| Page reordering, thumbnails, deletion | Planned | |
| Settings persistence (including accent) | Partial | Accent color persisted; additional settings planned |
| App lock and biometrics | Planned | |
| Backup and restore | Planned | Needs attachment design first |
| Native share and export | Planned | |
| Onboarding | Planned | |
| Audio and note timestamp sync | Planned | |
| Cloud sync and collaboration | Planned | Product is local-first today |

## 3. Technical work (not user features)

| Item | Status | Notes |
|---|---|---|
| Decompose editor screen and move media operations behind services | Done | `EditorSessionState` owns page/mode/selection/voice state; action and workspace parts plus injected services keep `NewNoteScreen` under 300 lines |
| Move plugin calls behind services | Done | `EditorMediaService`, `NoteAttachmentStorage` |
| Database and managed file storage for large notebooks | Done | SQLite stores each note separately; new attachment bytes are database blobs |
| Attachment lifecycle: missing files, cleanup, portability | Done | Old paths migrate to SQLite blobs; shared references are preserved and missing paths show a fallback |
| Tests for plugin flows (picker, microphone, speech, links) | Done (needs device test) | `editor_media_flow_test` | Fake flows cover success, denial, and picker/recording/speech/playback/opening failures; OS permission checks remain |
| Real SharedPreferences restart test | Done | Verified in `note_persistence_test` |
| Tests for trash restore, preview rendering, cleanup, and persistence errors | Done | `note_management_search_test`, `editor_navigation_test`, `note_attachment_storage_test`, `note_persistence_test` |
| Move editor out of `features/library/` | Done | Legacy path re-exports new editor feature path |

## 4. Current focus

*(The user fills this in. The AI updates it when work starts or ends.)*

- Working on: No active code task.
- Next: Check media and speech permissions on supported target devices/platforms.
- Waiting for the user: ISSUE-017 needs a real target device; this workspace has no Android/iOS emulator or device.

## 5. How to update this file

- When a task changes a feature's status, change its row in the same task.
- Keep the Notes column short and true.
- Do not delete rows. Change the status.
- Add the change to `change-log.md` as usual.
