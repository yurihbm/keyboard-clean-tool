import CoreGraphics
import Testing
@testable import KeyboardCleanTool

struct KeyboardCleanToolTests {

    @Test func escapeHatchMatchesOptionCommandShiftE() async throws {
        let flags: CGEventFlags = [.maskAlternate, .maskCommand, .maskShift]
        #expect(EscapeHatchShortcut.matches(keyCode: EscapeHatchShortcut.keyCode, flags: flags))
    }

    @Test func escapeHatchIgnoresWrongKeyCode() async throws {
        let flags: CGEventFlags = [.maskAlternate, .maskCommand, .maskShift]
        #expect(!EscapeHatchShortcut.matches(keyCode: 1, flags: flags))
    }

    @Test func escapeHatchRequiresAllModifiers() async throws {
        let flags: CGEventFlags = [.maskCommand, .maskShift]
        #expect(!EscapeHatchShortcut.matches(keyCode: EscapeHatchShortcut.keyCode, flags: flags))
    }

    @Test func escapeHatchRejectsExtraModifiers() async throws {
        let flags: CGEventFlags = [.maskAlternate, .maskCommand, .maskShift, .maskControl]
        #expect(!EscapeHatchShortcut.matches(keyCode: EscapeHatchShortcut.keyCode, flags: flags))
    }

    @Test func escapeHatchIgnoresIrrelevantFlags() async throws {
        let flags: CGEventFlags = [.maskAlternate, .maskCommand, .maskShift, .maskAlphaShift, .maskNumericPad]
        #expect(EscapeHatchShortcut.matches(keyCode: EscapeHatchShortcut.keyCode, flags: flags))
    }

    @Test func mediaKeyMaskIncludesSystemDefinedEventType() async throws {
        #expect(SystemDefinedEvent.isMediaKeyEventType(rawValue: SystemDefinedEvent.cgEventTypeRawValue))
    }

    @Test func mediaKeyMaskExcludesOrdinaryKeyEventTypes() async throws {
        #expect(!SystemDefinedEvent.isMediaKeyEventType(rawValue: CGEventType.keyDown.rawValue))
        #expect(!SystemDefinedEvent.isMediaKeyEventType(rawValue: CGEventType.flagsChanged.rawValue))
    }

    @Test func auxControlButtonSubtypeIsRecognizedAsMediaKey() async throws {
        #expect(SystemDefinedEvent.isAuxControlButton(subtype: SystemDefinedEvent.auxControlButtonSubtype))
    }

    @Test func nonAuxControlButtonSubtypeIsNotAMediaKey() async throws {
        #expect(!SystemDefinedEvent.isAuxControlButton(subtype: 0))
    }

}
