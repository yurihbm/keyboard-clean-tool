import ApplicationServices
import AppKit
import CoreGraphics
import Observation

@Observable
final class KeyboardBlocker {
    private(set) var isBlocking = false
    private(set) var lastError: String?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    var hasAccessibilityPermission: Bool {
        AXIsProcessTrusted()
    }

    func requestAccessibilityPermission() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    func start() {
        guard !isBlocking else { return }
        lastError = nil

        guard hasAccessibilityPermission else {
            lastError = "Accessibility permission is required."
            return
        }

        let mask: CGEventMask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << SystemDefinedEvent.cgEventTypeRawValue)

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let blocker = Unmanaged<KeyboardBlocker>.fromOpaque(refcon).takeUnretainedValue()
            return blocker.handle(type: type, event: event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            lastError = "Failed to start keyboard capture."
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        eventTap = tap
        runLoopSource = source
        isBlocking = true
    }

    func stop() {
        guard isBlocking else { return }
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
        isBlocking = false
    }

    deinit {
        stop()
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return nil
        }

        if type == .keyDown {
            let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))
            if EscapeHatchShortcut.matches(keyCode: keyCode, flags: event.flags) {
                DispatchQueue.main.async { [weak self] in
                    self?.stop()
                }
                return nil
            }
        }

        if SystemDefinedEvent.isMediaKeyEventType(rawValue: type.rawValue) {
            if let nsEvent = NSEvent(cgEvent: event),
               SystemDefinedEvent.isAuxControlButton(subtype: nsEvent.subtype.rawValue) {
                return nil
            }
            return Unmanaged.passUnretained(event)
        }

        return nil
    }
}
