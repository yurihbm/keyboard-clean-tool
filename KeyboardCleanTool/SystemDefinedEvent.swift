import CoreGraphics

/// Media/function keys (volume, play/pause, brightness, etc.) arrive as NX_SYSDEFINED
/// events, not as `CGEventType.keyDown` — they need to be tapped and identified separately.
enum SystemDefinedEvent {
    static let cgEventTypeRawValue: UInt32 = 14 // NX_SYSDEFINED
    static let auxControlButtonSubtype: Int16 = 8 // NX_SUBTYPE_AUX_CONTROL_BUTTON

    static func isMediaKeyEventType(rawValue: UInt32) -> Bool {
        rawValue == cgEventTypeRawValue
    }

    static func isAuxControlButton(subtype: Int16) -> Bool {
        subtype == auxControlButtonSubtype
    }
}
