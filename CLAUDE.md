# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

This `point` folder is a small monorepo for the Ledger app:

- **`ios/`** — the SwiftUI/Core Data iOS app (Xcode project, generated via XcodeGen). See **`iOS/CLAUDE.md`** for the full architecture, build/test commands, and toolchain notes — read that file before working on the app itself.
- **`design/`** — wireframe/Figma design reference for the app's UI, kept outside the iOS project folder since it isn't part of the buildable app.
- **`android/`** - the 

There is no other platform folder yet (no backend, no web/Android client) — everything here is the iOS app plus its design reference.