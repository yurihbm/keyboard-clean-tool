# AGENTS.md

Instructions for coding agents working in this repository.

## What this project is

Keyboard Clean Tool is a small macOS app that temporarily disables the keyboard so it can be cleaned without triggering keystrokes. See `README.md` for the full picture before making changes — it explains the core mechanism and project structure.

## Build & test

Always use `xcodebuild` from the repo root (no CocoaPods/SPM dependencies to resolve):

```sh
# Build
xcodebuild -project KeyboardCleanTool.xcodeproj -scheme KeyboardCleanTool -destination 'platform=macOS' build

# Run the full test suite
xcodebuild test -project KeyboardCleanTool.xcodeproj -scheme KeyboardCleanTool -destination 'platform=macOS'

# Run a single test target/class
xcodebuild test -project KeyboardCleanTool.xcodeproj -scheme KeyboardCleanTool -destination 'platform=macOS' -only-testing:KeyboardCleanToolTests
```

A change is not done until `xcodebuild test` passes. Don't rely on SourceKit/editor diagnostics alone — they lag behind real compiler state in this environment; always confirm with an actual build.

## Test-driven development is mandatory

For any new logic, bug fix, or behavioral change:

1. Write a failing test first.
2. Run it and confirm it fails for the expected reason (not a typo or setup error).
3. Write the minimum code to make it pass.
4. Refactor while keeping tests green.

For pure refactors (no behavior change), make sure existing tests still pass; add coverage only if it's missing. For non-logic changes (docs, formatting, asset tweaks), tests aren't required.

`EscapeHatchShortcut` and `SystemDefinedEvent` are the reference example: they're pure, dependency-free logic pulled out of `KeyboardBlocker`, so the shortcut-matching and media-key-detection rules are fully testable (`KeyboardCleanToolTests/KeyboardCleanToolTests.swift`) without touching the real `CGEventTap`. Follow this pattern — anything that talks to a system API (CGEventTap, Accessibility, file system) should have its decision logic extracted into small, pure, testable units.

## Project structure

```
KeyboardCleanTool/
├── KeyboardCleanToolApp.swift  # App entry point, owns the AppDelegate
├── KeyboardBlocker.swift       # Owns the CGEventTap lifecycle and blocking state
├── EscapeHatchShortcut.swift   # Matches the ⌥⌘⇧E re-enable shortcut from raw event data
├── SystemDefinedEvent.swift    # Identifies media-key (NX_SYSDEFINED) events
├── ContentView.swift           # The app's UI
├── Localizable.xcstrings       # String catalog (en, pt-BR)
├── AppIcon.icon                 # App icon, authored with Icon Composer
└── Assets.xcassets

KeyboardCleanToolTests/   # Unit tests (Swift Testing framework, not XCTest)
```

`KeyboardCleanTool/` and `KeyboardCleanToolTests/` are Xcode **synchronized groups**: any file you add on disk inside these folders is automatically picked up as a target member — you never need to touch `project.pbxproj` to add a Swift file. You only need to edit `project.pbxproj` directly for project-level settings (build settings, `knownRegions`, target config), and even then, prefer doing so surgically.

## Conventions to follow

- **Swift Testing, not XCTest.** New tests use `import Testing` and `@Test func ...` / `#expect(...)`, matching the existing test file.
- **`@Observable`, not `ObservableObject`.** State-holding reference types use the `Observation` framework's `@Observable` macro (see `KeyboardBlocker`), consistent with the macOS 26 deployment target.
- **Localize user-facing strings.** Any text shown in the UI goes through `KeyboardCleanTool/Localizable.xcstrings` with both `en` and `pt-BR` entries — never hardcode a literal string in a `Text`/`Button` label. Diagnostic/internal strings meant only for logs don't need localization.
- **Pure logic stays out of `KeyboardBlocker`.** Anything that can be expressed as a pure function over raw event data (shortcut matching, event-type classification) belongs in its own small enum/struct, not inline in the event tap callback — that's what keeps it unit-testable.

## Release process

Use the `release` skill (`.claude/skills/release/SKILL.md`) — invoked via `/release` — which covers how CI builds and ships a release and the tap-update mechanics.

## General engineering rules

- Make surgical changes: touch only what the task requires, match existing style, don't refactor unrelated code.
- Don't add error handling, abstractions, or configurability that isn't needed for the task at hand.
- Before any destructive git operation (`reset --hard`, `checkout` over uncommitted changes, force push), check `git status` first and stop if there's uncommitted work that isn't yours to discard.
- Verify UI-affecting changes by actually building and running the app (`open` the built `.app` from `DerivedData`), not just by reading the code.
