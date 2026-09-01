# Keyboard Clean Tool

A simple macOS app that temporarily disables your keyboard so you can clean it without triggering keystrokes.

## How it works

The app uses a `CGEventTap` to intercept and swallow keyboard events (key down, key up, modifier changes) system-wide while "Cleaning Mode" is active. Media keys are left untouched. If the event tap gets disabled by the system (e.g. due to timeout), it's automatically re-enabled.

Since intercepting keyboard events system-wide requires elevated access, the app needs **Accessibility permission** to work.

## Usage

1. Launch the app and grant Accessibility permission when prompted (System Settings → Privacy & Security → Accessibility).
2. Click **Start Cleaning Mode** to disable the keyboard.
3. Clean your keyboard.
4. Click **Stop Cleaning Mode**, or press **⌥⌘⇧E** at any time to immediately re-enable the keyboard.

The keyboard is also automatically re-enabled if the app quits.

## Requirements

- macOS
- Xcode (to build and run)

## Building

Open `KeyboardCleanTool.xcodeproj` in Xcode and run the `KeyboardCleanTool` scheme.

## Status

Personal project, built for my own use.
