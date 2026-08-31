# 🚀 Advanced Note Editing — Functional GitHub Issues & Branch Plan

This document organizes the **Advanced Note Editing** specifications strictly by **Functional Modules** and **Git Feature Branches**.

---

## 📌 Issue #10: feat(text): Rich Text Box Engine & Basic Text Tools
**Git Branch**: `feature/text-box-engine`

### 🎯 Objective
Implement the core text engine allowing users to create, edit, move, resize, and position text boxes anywhere on the digital page.

### 📋 Functional Tasks
- [ ] Text Tool activation state & UI indicator
- [ ] Tap-to-place text box creation on canvas
- [ ] Text editing without creating duplicate text objects
- [ ] Move text box across canvas
- [ ] Resize text box with dynamic text reflow / wrapping
- [ ] Font family picker, font size adjustment, text color picker
- [ ] Text alignment controls (Left, Center, Right)
- [ ] Delete text box action

---

## 📌 Issue #11: feat(text-formatting): Advanced Text Formatting & Lists
**Git Branch**: `feature/text-formatting-lists`

### 🎯 Objective
Extend the text engine with rich text formatting (Bold, Italic, Underline, Strikethrough) and structured list support.

### 📋 Functional Tasks
- [ ] Bold text formatting toggle
- [ ] Italic text formatting toggle
- [ ] Underline text formatting toggle
- [ ] Strikethrough text formatting toggle
- [ ] Bullet list support (`• Item`)
- [ ] Numbered list support (`1. Item`)
- [ ] Interactive Checklist support (`[ ] Task`)
- [ ] Persistence of formatted text & list structure

---

## 📌 Issue #12: feat(shapes): Vector Shape Tools & Geometric Rendering
**Git Branch**: `feature/vector-shapes`

### 🎯 Objective
Build vector shape engine allowing users to insert, style, and transform geometric shapes and diagrams.

### 📋 Functional Tasks
- [ ] Vector shape generators: Line, Arrow, Rectangle, Rounded Rectangle, Circle, Ellipse, Triangle, Polygon
- [ ] Shape stroke/border color picker & stroke thickness slider
- [ ] Shape fill color picker & opacity control
- [ ] Shape manipulation controls (Move, Resize, Rotate, Delete, Duplicate)

---

## 📌 Issue #13: feat(shape-rec): Intelligent Freehand Shape Recognition Engine
**Git Branch**: `feature/shape-recognition`

### 🎯 Objective
Build real-time shape recognition engine that automatically converts rough freehand stroke drawings into clean vector geometric shapes.

### 📋 Functional Tasks
- [ ] Freehand stroke gesture analysis (detect closed loops, straight lines, corners)
- [ ] Convert rough circle drawing into vector Circle object
- [ ] Convert rough rectangle/square drawing into vector Rectangle object
- [ ] Convert rough line/arrow stroke into clean Line / Arrow object
- [ ] Convert rough triangle drawing into vector Triangle object
- [ ] Handwriting protection (prevent regular handwriting from being incorrectly converted)

---

## 📌 Issue #14: feat(lasso): Lasso Selection & Multi-Object Grouping
**Git Branch**: `feature/lasso-selection`

### 🎯 Objective
Implement freehand lasso tool allowing users to select, group, and transform handwriting strokes, text, shapes, and images together.

### 📋 Functional Tasks
- [ ] Freehand Lasso gesture tool (`CustomPainter` lasso outline path)
- [ ] Bounding box & hit test intersection algorithm
- [ ] Single stroke vs Multi-stroke selection
- [ ] Mixed object selection (Handwriting + Text + Shape + Image)
- [ ] Group transformations (Move, Preserve relative positions, Resize, Rotate, Delete, Deselect)

---

## 📌 Issue #15: feat(clipboard): Clipboard & Cross-Page Object Manipulation
**Git Branch**: `feature/clipboard-operations`

### 🎯 Objective
Implement Copy, Cut, Paste, and Duplicate capabilities for all note objects across pages and notes.

### 📋 Functional Tasks
- [ ] Internal Clipboard manager supporting Handwriting, Text, Shapes, Images
- [ ] Copy, Cut, Paste, and Duplicate actions
- [ ] Cross-page paste (Page 1 ➔ Page 2) & Cross-note paste
- [ ] Deep clone object independence (pasted duplicates remain 100% independent)

---

## 📌 Issue #16: feat(images): Image Attachment & Annotation Layering
**Git Branch**: `feature/image-attachment`

### 🎯 Objective
Allow users to import photos/images from gallery or camera into notes and annotate over them with handwriting and text.

### 📋 Functional Tasks
- [ ] Image picker integration (Gallery, Camera, File picker)
- [ ] Image object renderer on canvas
- [ ] Image transformations (Move, Resize, Rotate, Crop, Delete, Duplicate)
- [ ] Multi-layer Z-ordering (Handwriting / Text / Shape / Image hierarchy)

---

## 📌 Issue #17: feat(organization): Folder Organization, Favorites & Page Reordering
**Git Branch**: `feature/folder-organization`

### 🎯 Objective
Provide document organization tools including Folders, Favorites, Pinning, Library Sorting, and Advanced Page Management.

### 📋 Functional Tasks
- [ ] Page thumbnails panel, Duplicate page, Insert page, Page reordering
- [ ] Create, Rename, Delete Folders; Move notes into/out of folders
- [ ] Favorite / Unfavorite notes & Pin / Unpin notes
- [ ] Library Sorting (Name, Modified Date, Created Date)

---

## 📌 Issue #18: feat(rich-note-polish): Rich Editor Integration, Undo/Redo & Gate QA
**Git Branch**: `feature/rich-editor-integration`

### 🎯 Objective
Integrate all rich editing features into a cohesive document editor, extend Undo/Redo history to rich objects, and execute the Gate QA workflow.

### 📋 Functional Tasks
- [ ] Extend Undo/Redo history stack for Text, Shapes, Images, and Transformations
- [ ] Local storage persistence for rich objects, object positions, and folder state
- [ ] Performance optimization for complex pages
- [ ] Execute Complete Rich Note Workflow (Test 113 / Test 152)
