# 🚀 Notability Clone — Functional GitHub Issues & Branch Plan

This document organizes the Core Notebook requirements strictly by **Functional Modules** and **Git Feature Branches**. 
There are **no Day or Week references**. Each issue maps directly to a Git feature branch for clean, modular development.

---

## 🛠️ Feature Branch Workflow Quick Start

To publish all functional issues to GitHub:
```bash
python3 scripts/create_github_issues.py
```
*(Make sure to authenticate `gh` first via `gh auth login` or `export GH_TOKEN=your_token`)*

---

## 📌 Issue 1: feat(core): App Foundation, UI Theme & Library Screen
**Labels**: `feature`, `core-ui`  
**Git Branch**: `feature/foundation-library`

### 🎯 Objective
Build the core application structure, theme system, router, and initial Library screen.

### 📋 Functional Tasks
- [ ] Set up Flutter project directory structure
- [ ] Implement App Theme (Colors, Typography, Spacing)
- [ ] Configure router and app navigation (`/`, `/editor`)
- [ ] Build Library Screen scaffold with header & title
- [ ] Implement Empty Library state component
- [ ] Add "+ Create Note" floating action button / action trigger
- [ ] Build reusable UI widgets (AppButton, AppIconButton)

### 🧪 Related Test Cases
- **Test 1 — App Launch**: App launches without crashing, Home/Library appears correctly.
- **Test 2 — Empty Library**: Clear empty state guiding the user to create their first note.
- **Test 3 — Create New Note**: Tapping `+` creates note and opens Note Editor without duplicates.
- **Test 4 — Library Display**: Newly created note appears immediately in the library list.

---

## 📌 Issue 2: feat(notes): Note Management, Metadata & Title Search
**Labels**: `feature`, `note-management`  
**Git Branch**: `feature/note-management-search`

### 🎯 Objective
Implement Note data models, CRUD operations (Create, Rename, Delete), metadata handling, and note searching.

### 📋 Functional Tasks
- [ ] Define `Note` data model (ID, title, pageCount, modifiedDate, createdDate, thumbnailPath)
- [ ] Implement Note creation logic with default title naming
- [ ] Implement Note renaming capability across Library & Editor views
- [ ] Implement Note deletion logic with confirmation modal
- [ ] Build Note Card widget (grid/list view showing page count, modified date, thumbnail placeholder)
- [ ] Implement live Title Search filtering algorithm

### 🧪 Related Test Cases
- **Test 5 — Rename Note**: Renaming updates Title in Library and Editor, surviving app restart.
- **Test 6 — Open Correct Note**: Tapping a note opens only its corresponding content.
- **Test 7 — Delete Note**: Deleting a note leaves all other notes untouched.
- **Test 8 — Basic Note Search**: Searching by title filters notes accurately.

---

## 📌 Issue 3: feat(paper): Paper Template Engine & Customization
**Labels**: `feature`, `paper-engine`  
**Git Branch**: `feature/paper-templates`

### 🎯 Objective
Build background paper rendering system supporting multiple paper patterns, background colors, and orientations.

### 📋 Functional Tasks
- [ ] Create `PaperTemplate` configuration data structure
- [ ] Build Blank Paper background renderer
- [ ] Build Ruled Paper renderer (horizontal guidelines attached to page coordinates)
- [ ] Build Grid Paper renderer (grid lines fixed to page coordinate space)
- [ ] Build Dotted Paper renderer (evenly spaced dots)
- [ ] Implement Paper Color picker & background color switcher
- [ ] Implement Page Orientation configuration (Portrait / Landscape)

### 🧪 Related Test Cases
- **Test 9 — Blank Paper**: Plain background renders without lines or dots.
- **Test 10 — Ruled Paper**: Horizontal lines render and remain attached to page during pan/zoom.
- **Test 11 — Grid Paper**: Grid cells remain correctly aligned during zoom/pan.
- **Test 12 — Dotted Paper**: Dots maintain correct spacing and coordinate alignment.
- **Test 13 — Paper Color**: Background color changes and persists.
- **Test 14 — Orientation**: Portrait & Landscape maintain correct page dimensions.

---

## 📌 Issue 4: feat(canvas): Touch Input, Handwriting Engine & Viewport Controls
**Labels**: `feature`, `canvas`, `handwriting`  
**Git Branch**: `feature/handwriting-canvas`

### 🎯 Objective
Build the core handwriting engine to capture touch movement smoothly and render strokes on a pan/zoom canvas.

### 📋 Functional Tasks
- [ ] Touch Event Listener (`GestureDetector` / `Listener` for Down, Move, Up)
- [ ] `Stroke` & `TouchPoint` data models
- [ ] Real-time canvas painter (`CustomPainter` / path painter)
- [ ] Touch input support for Finger writing & Capacitive Stylus
- [ ] Viewport navigation & transformation matrix:
  - [ ] Smooth Pan (drag navigation without drawing accidental strokes)
  - [ ] Pinch Zoom In / Zoom Out
  - [ ] Reset Zoom action
- [ ] Ensure stroke independence (each stroke maintained as a separate object)

### 🧪 Related Test Cases
- **Test 15 — Canvas Loading**: Canvas fills viewport without clipping.
- **Test 16–19 — Viewport Control**: Zoom in/out, pan, and reset zoom keep stroke coordinates fixed.
- **Test 20 — Finger Writing**: Stroke follows finger accurately with acceptable latency.
- **Test 21 — Capacitive Pen**: Input behaves predictably with ordinary capacitive stylus.
- **Test 22–26 — Stroke Engine**: Separate strokes captured without joining, fast/slow writing smooth, freehand drawings stored as strokes.

---

## 📌 Issue 5: feat(tools): Digital Writing Tools (Pen, Pencil, Highlighter, Eraser)
**Labels**: `feature`, `writing-tools`  
**Git Branch**: `feature/writing-tools`

### 🎯 Objective
Implement digital writing and erasing tools with customizable properties, visual styles, and active tool state management.

### 📋 Functional Tasks
- [ ] **Active Tool State Manager**: Clean tool switching between Pen ↔ Pencil ↔ Highlighter ↔ Eraser
- [ ] **Pen Tool**: Color palette, stroke thickness slider/selector, opacity control, presets selector
- [ ] **Pencil Tool**: Textured stroke rendering, color, thickness, opacity controls
- [ ] **Highlighter Tool**: Semi-transparent rendering, multiple colors, text readability preservation
- [ ] **Eraser Tool**: Size selection (Small/Large), stroke/object-based erasing, continuous drag erasing

### 🧪 Related Test Cases
- **Test 27–31 — Pen Tool**: Pen activates, color/thickness/opacity settings apply to new strokes. Presets work.
- **Test 32–33 — Pencil Tool**: Pencil has distinct visual style, switches cleanly with Pen.
- **Test 34–37 — Highlighter Tool**: Semi-transparent highlight renders over writing without obscuring text.
- **Test 38–41 — Eraser Tool**: Erases target stroke cleanly while leaving unrelated strokes intact across pages.

---

## 📌 Issue 6: feat(history): Undo & Redo History System
**Labels**: `feature`, `history`  
**Git Branch**: `feature/undo-redo-stack`

### 🎯 Objective
Implement action history manager supporting multi-step Undo and Redo operations for stroke creation and erasing.

### 📋 Functional Tasks
- [ ] Define `CanvasAction` command stack (AddStrokeAction, RemoveStrokeAction)
- [ ] Build Undo stack manager
- [ ] Build Redo stack manager
- [ ] Support multiple consecutive Undo / Redo operations
- [ ] Handle action stack branching (performing new edit after Undo invalidates Redo stack)

### 🧪 Related Test Cases
- **Test 42 — Undo Writing**: Last stroke action disappears cleanly.
- **Test 43 — Redo Writing**: Undone stroke action returns cleanly.
- **Test 44 — Undo Erasing**: Erased content is restored to canvas.
- **Test 45–47 — Action Branching**: Multiple undos/redos reverse/restore in exact order; new actions invalidate old redo branches.

---

## 📌 Issue 7: feat(pages): Multi-Page Engine & Page Navigation
**Labels**: `feature`, `multi-page`  
**Git Branch**: `feature/multi-page-system`

### 🎯 Objective
Build multi-page document architecture including page creation, page removal, thumbnail overview, and page switching.

### 📋 Functional Tasks
- [ ] Implement `Page` model and page collection management within a Note
- [ ] Add new page action
- [ ] Delete page action with page re-indexing
- [ ] Forward & Backward page navigation controls
- [ ] Page counter indicator (e.g., "Page 2 of 5")
- [ ] Build Page Thumbnails sheet / sidebar grid
- [ ] Jump to page via thumbnail tap
- [ ] Enforce Page Content Isolation (Page 1 strokes stay strictly on Page 1)

### 🧪 Related Test Cases
- **Test 48 — Add Page**: New page appears correctly in document.
- **Test 49 — Page Isolation**: Content on Page 1 remains strictly isolated from Page 2 and Page 3.
- **Test 50–52 — Navigation & Thumbnails**: Page switching & thumbnail selection jump to correct page.
- **Test 53–54 — Page Deletion & Count**: Deleting a page re-indexes remaining pages and updates total count.

---

## 📌 Issue 8: feat(persistence): Local Storage & Auto-Save Recovery Engine
**Labels**: `feature`, `persistence`, `storage`  
**Git Branch**: `feature/local-storage-autosave`

### 🎯 Objective
Implement persistent local storage database and auto-save background engine to protect user notes against data loss.

### 📋 Functional Tasks
- [ ] Configure local database / persistence layer (Hive / Isar / SQLite)
- [ ] Create database schemas & mappers for Notes, Pages, Strokes, TouchPoints, Tool Configurations
- [ ] Implement Auto-Save background engine (debounced auto-save on stroke complete / edit)
- [ ] Implement state restoration on note opening / app startup
- [ ] Support multi-page persistence and stroke property persistence (color, thickness, opacity, tool type)
- [ ] Implement Force-Close recovery handling (persisted edits survive app force-kill)

### 🧪 Related Test Cases
- **Test 55 — Basic Persistence**: Note content survives app close & reopen.
- **Test 56 — Multi-Page Persistence**: All pages & respective strokes persist intact.
- **Test 57–58 — Tool & Metadata Persistence**: Titles, paper types, colors, and strokes retain exact visual styling.
- **Test 59 — Auto-Save**: No manual save action required.
- **Test 60–62 — Force-Close Recovery**: Edits remain fully recovered after force-stopping the application.

---

## 📌 Issue 9: feat(polish): Core Notebook Integration, Performance & Gate Acceptance
**Labels**: `feature`, `integration`, `qa`  
**Git Branch**: `feature/integration-polish`

### 🎯 Objective
Integrate all functional modules (Library, Canvas, Tools, Pages, Persistence) into a polished, production-ready core notebook and run end-to-end QA.

### 📋 Functional Tasks
- [ ] Integrate Home ↔ Editor ↔ Toolbar ↔ Pages ↔ Storage seamlessly
- [ ] UI & Component Polish (toolbar layouts, icons, card shadows, empty states, micro-animations)
- [ ] Dialogs & Modals (delete confirmation modals, error handling toasts)
- [ ] Responsive Layout Testing (Phone Portrait, Landscape, Tablet screen adaptability)
- [ ] Performance Optimization (smooth rendering with 500+ strokes across multiple pages)
- [ ] Execute Complete 23-step End-to-End Acceptance Test (Test 63)

### 🧪 Complete End-to-End Verification (Test 63)
- [ ] 1. Open app ➔ Create "Biology Notes"
- [ ] 2. Select Ruled Paper ➔ Write with Finger & Capacitive Pen
- [ ] 3. Switch Pen Color, Thickness, Pencil, Highlighter
- [ ] 4. Test Eraser, Undo, Redo
- [ ] 5. Add Page 2 ➔ Write ➔ Add Page 3 ➔ Navigate pages
- [ ] 6. Return to Home ➔ Reopen Note ➔ Force Close App ➔ Reopen App
- [ ] 7. Verify all pages and strokes are 100% intact
