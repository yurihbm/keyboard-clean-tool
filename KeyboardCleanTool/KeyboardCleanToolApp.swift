import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    var blocker: KeyboardBlocker?

    func applicationWillTerminate(_ notification: Notification) {
        blocker?.stop()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct KeyboardCleanToolApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var blocker = KeyboardBlocker()

    var body: some Scene {
        WindowGroup {
            ContentView(blocker: blocker)
                .onAppear { appDelegate.blocker = blocker }
        }
        .windowResizability(.contentSize)
    }
}
