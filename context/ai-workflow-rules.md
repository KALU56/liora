# AI Workflow

General rules for how the AI works. They are true for any project.
Project details are in the other files in `context/`.

## 1. Understand first

Before you write or change anything:

- Look at the directory structure of the project and of `context/`.
- Read the `context/` files that match the task.
- Read the existing code related to the task. Follow how it is used, not only
  where it is written.
- If the task is unclear, ask. Do not guess.

## 2. Do only what was asked

- Change only what the task needs.
- No unrelated changes: no renaming, no reformatting, no "cleanup", no extra
  features, no moving code around.
- If you see another problem, do NOT fix it. Tell me at the end, and add it to
  `current-issues.md` if that file exists.
- Do not add things "just in case" or for the future.

## 3. Small task or big task

**Small task** (one feature, a few lines, easy to undo): do it, then report.

**Big task** (many files, new behavior, or hard to undo): first write a short plan:

1. What you understood
2. What you will change (files)
3. What you will not touch
4. How you will test it

Then wait for my OK.

If you are not sure whether it is small or big, treat it as big.

## 4. Ask me first (STOP and wait for my answer)

Always ask before:

- Adding, removing, or upgrading a dependency
- Creating, moving, renaming, or deleting files or folders
- Changing how saved data is stored or its format (old data could break)
- Large refactors
- Deleting, skipping, or weakening tests
- Editing platform, build, or configuration files
- Anything with more than one reasonable solution

When you ask: explain what, why, and what could go wrong. Give your
recommendation. One question at a time.

## 5. Work in small steps

- One thing at a time.
- After each step, the project should still run.
- Do not leave half-finished code.
- If you get stuck or a fix is not working after two tries, stop and tell me.
  Do not keep guessing.

## 6. Code standards (general)

These rules apply to any project. Project-specific standards (language, naming
style, commands) are in `code-standards.md`. If the two disagree,
`code-standards.md` wins.

**Follow the project, not your taste**
- Match the style, naming, and structure of the code that already exists.
- Reuse existing code, helpers, and patterns before you write new ones.
- Do not introduce a new pattern or library when the project already has a way.

**Readable code**
- Use clear names that say what a thing is or does. No unclear short names.
- Keep functions and files small and focused on one job.
- Prefer simple code over clever code.
- Write comments to explain WHY, not WHAT. Do not comment obvious code.

**Clean changes**
- No dead code, no commented-out code, no leftover debug prints or TODOs
  that you created.
- No duplicated code. If you copy code a second time, stop and make it shared.
- No hardcoded values that should be constants or settings.
- No secrets, keys, or passwords in code.

**Safe code**
- Handle errors and empty or missing data. Do not ignore failures silently.
- Do not trust user input or files. Check them.
- Do not change a public interface, model, or data format without asking.

**Layers and structure**
- Keep each layer to its own job (see `architecture.md`). Do not skip layers.
- Do not put business logic inside UI code.

## 7. Test and check

- Run the related tests and static analysis after every code change.
  (The commands are in `code-standards.md`.)
- Add or update tests for every behavior change.
- Say clearly what you ran and what the result was.
- If you could not run something, say so. Never say "it works" or "tests pass"
  if you did not check.


- Run static analysis and tests after changes:
  - `flutter analyze`
  - `flutter test` (or the specific test file: `flutter test test/<test_file>.dart`)
- Add or update tests for every behavior change.
- Report exact test results. Never claim tests pass without running them.
## 8. Be honest

- If you are not sure, say so.
- If a context file and the code disagree, tell me. The code is the truth.
- If you made a mistake, tell me, then fix it.
- Never invent file names, functions, or features. Check that they exist.

## 9. Change log (required)

Every task ends with a new entry at the TOP of `context/change-log.md`.
**A task is not finished until the entry is written.**

Rules:
- One entry per task. Newest entry on top.
- Write only what is true. Do not write that you tested something you did not.
- Show the old way and the new way. Keep each line short and clear.
- Use the date of the task.
- Do not edit or delete old entries.

Format:

```
## YYYY-MM-DD: Short title
- **Before:** how it worked / looked / was written before
- **After:** how it works / looks / is written now
- **Why:** the reason for the change
- **Files changed:** list of files (say if a file was added or deleted)
- **Tests run:** test files and result (or "not run" + reason)
- **Check by hand:** what I should test on the device
- **Needs your attention:** questions, risks, problems you saw but did not fix,
  or "none"
```

## 10. Update the context files

If your work changes what the context files say, update them:

- A feature's status changed -> `progress-tracker.md`
- You found or fixed a problem -> `current-issues.md`
- You changed the structure or flow -> `architecture.md`
- You changed a UI screen -> `ui-context.md`
- You changed a rule or standard -> `code-standards.md`

## 11. Definition of done

- [ ] The task I asked for is done, and nothing else was changed
- [ ] The code follows the code standards (section 6 and `code-standards.md`)
- [ ] Analysis is clean and related tests pass (or I was told what was not run)
- [ ] `change-log.md` has a new entry (before -> after)
- [ ] The related context files are updated
- [ ] I was told what to check by hand

## 12. How to talk to me

- Use simple, clear English. Short sentences.
- Say what you will do before you do it (for big tasks).
- After the task, tell me: what changed, what I should test by hand, and any
  problem you saw but did not fix.