import CoreGraphics

/// The keyboard shortcut (⌥⌘⇧E) that stops blocking, matched from raw CGEventTap data.
enum EscapeHatchShortcut {
    static let keyCode: CGKeyCode = 14 // kVK_ANSI_E
    private static let requiredFlags: CGEventFlags = [.maskAlternate, .maskCommand, .maskShift]
    private static let relevantFlags: CGEventFlags = [.maskAlternate, .maskCommand, .maskShift, .maskControl]

    static func matches(keyCode: CGKeyCode, flags: CGEventFlags) -> Bool {
        guard keyCode == Self.keyCode else { return false }
        return flags.intersection(relevantFlags) == requiredFlags
    }
}
