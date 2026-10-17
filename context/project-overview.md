# Project Overview

What PaperNote is, who it is for, and what exists today.
**The code is the source of truth.** If this file and the code disagree, tell the
user and update this file.

## 1. Purpose

PaperNote is a local-first, cross-platform digital notebook built with Flutter.
A user can create notebooks, write or draw on editable paper pages, add typed
text and media, and come back to saved work later.

Main product goal: combine a simple notebook library with a flexible page editor,
without needing an account or network connection for ordinary note taking.

This repository is a **working product prototype**, not a complete Notability
replacement. The issue-plan documents in `docs/` describe desired work. They are
**not proof** that those features exist.

## 2. Users and their needs

| User | Needs |
|---|---|
| Students and learners | Class notes, diagram sketches, ruled/grid/dotted paper, audio recording while working |
| Meeting and lecture attendees | Typed or dictated notes, images/files/links, recordings attached to pages |
| People who prefer handwriting | Finger or stylus input, pen styles, eraser, shapes, undo and redo |
| Everyday note takers | Create, rename, search, and organize notes in a local library |

The app is **single-user and device-local**. There is no sign-in, account sync,
collaboration, or cloud backup.

## 3. What works today

| Area | Available behavior |
|---|---|
| Library | Empty state, create/open notes, rename, delete with confirmation, title search, list/grid view, accent color picker |
| Note lifecycle | A note has an ID, title, page count, and timestamps. A blank title becomes `Untitled Note`. The editor auto-saves |
| Pages | Independent pages. Add pages and move between them. Each page keeps its own paper, strokes, text, attachments, and tool settings |
| Paper | Blank, ruled, grid, dotted. Background color, portrait/landscape, page size, pattern spacing |
| Handwriting | Touch/stylus strokes. Pen, pencil, highlighter, eraser, shapes, ruler. Settings for color, width, opacity, eraser size, shape kind, fill |
| Editing | Undo/redo for canvas actions, clear canvas, text blocks (style, alignment, position), select and restyle text and strokes, drag text, zoom |
| Content | Image and file picking, link attachment, audio recording, and speech-to-text dictation. Attachments are stored as paths/strings in page data |
| Appearance | Material light and dark themes follow the system. The accent color can be changed while the app runs |
| Persistence | Notes are saved as one JSON snapshot in `shared_preferences`. Writes are queued in order. Data is restored on launch |

**Platform note:** file pickers, microphone, speech recognition, and playback
depend on platform permissions and plugin support. Check the platform manifests
and test on real devices before calling these flows production-ready.

**Limits today (small but important):**
- Accent color is not saved. It resets when the app restarts.
- Library search looks at note **titles only**, not page text or attachments.
- Grid-view thumbnails are placeholders, not real page previews.
- Deleting a note is permanent. There is no trash or recovery.
- Undo/redo covers canvas actions only, not text edits.

## 4. Not built yet (roadmap)

These appear in issue plans but are **not** complete product features in the
current code:

- PDF import, viewing, search, export
- Folders and favorites
- Trash and recovery
- Global content search (page text, attachments)
- Clipboard, lasso, and group selection
- Shape recognition
- Rich list formatting
- Page reordering, thumbnails, page deletion
- Settings persistence
- App lock and biometrics
- Backup and restore
- Native share and export
- Onboarding
- Cloud sync and collaboration
- Audio playback with timestamp sync to notes (audio recording and basic
  playback exist, but the full workflow does not)

Some lower-level types or package declarations may exist without a finished
end-to-end feature. Before you call any item "done", check it in the source and
tests. Treat `docs/*_GITHUB_ISSUES.md` as backlog input only. Its checkboxes may
be old or wishful.

## 5. Tech stack

- **Flutter / Dart**, Material and Cupertino widgets
- `shared_preferences`: local note snapshot
- `file_picker`, `image_picker`: choose files and images
- `record`, `audioplayers`: audio recording and playback
- `path_provider`: app storage folders
- `speech_to_text`: dictation
- `url_launcher`: open links
- Platforms: Android, iOS, macOS, Windows, Linux, Web

A package in `pubspec.yaml` does **not** mean its feature is complete, tested, or
production ready.

## 6. Product principles

- **Local-first.** Ordinary note taking must work with no account and no network.
- **Do not lose user data.** Auto-save must keep working. Old notes must still
  open after an update.
- **Page isolation.** Each page keeps its own content and history.
- **Honest scope.** Do not describe roadmap items as available features.
- **Simple library, flexible editor.** Keep the library easy, and put the power
  in the page editor.

## 7. Where to read next

| You need | Read |
|---|---|
| Code structure and data flow | `architecture.md` |
| Rules for writing code and tests | `code-standards.md` |
| Screens and controls | `ui-context.md` |
| Status of each feature | `progress-tracker.md` |
| Known bugs and problems | `current-issues.md` |