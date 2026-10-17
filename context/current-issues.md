# Current Issues

This file lists outstanding work only. Resolved issues remain in
`change-log.md`.

## Open issues

### ISSUE-017: Media, microphone, and speech need device checks
- **Type:** Platform
- **Severity:** Medium
- **Status:** Open
- **Where:** `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/` manifests and plugins
- **What happens:** These flows depend on OS permissions and platform plugin support. Automated fakes do not confirm that they work on every target.
- **Expected:** Verify media picking, file opening, recording, and speech on each supported target platform.
- **Notes:** Linux and Chrome are available in the workspace. The Linux build needs host GStreamer development files, and no Android/iOS device or emulator is connected.
