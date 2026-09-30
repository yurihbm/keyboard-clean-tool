import Combine
import SwiftUI

struct ContentView: View {
    let blocker: KeyboardBlocker
    @State private var hasPermission = false
    @State private var permissionCheckCancellable: AnyCancellable?

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 24) {
                Image(systemName: "keyboard")
                    .symbolVariant(blocker.isBlocking ? .slash : .none)
                    .font(.system(size: 64))
                    .symbolEffect(.bounce, value: blocker.isBlocking)
                    .foregroundStyle(blocker.isBlocking ? .secondary : .primary)

                Text(
                    blocker.isBlocking
                        ? String(localized: "keyboard.status.disabled", defaultValue: "Keyboard is disabled")
                        : String(localized: "keyboard.status.active", defaultValue: "Keyboard is active")
                )
                .font(.title2.weight(.semibold))

                if !hasPermission {
                    permissionPrompt
                } else {
                    toggleButton
                    if let lastError = blocker.lastError {
                        Text(lastError)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(
                            String(
                                localized: "keyboard.hint.escape",
                                defaultValue: "Press ⌥⌘⇧E anytime to re-enable the keyboard."
                            )
                        )
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(40)
        }
        .frame(width: 360, height: 320)
        .onAppear { refreshPermission() }
        .onDisappear { permissionCheckCancellable = nil }
    }

    private func refreshPermission() {
        hasPermission = blocker.hasAccessibilityPermission
        guard !hasPermission, permissionCheckCancellable == nil else { return }

        permissionCheckCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                hasPermission = blocker.hasAccessibilityPermission
                if hasPermission {
                    permissionCheckCancellable = nil
                }
            }
    }

    private var toggleButton: some View {
        Button {
            blocker.isBlocking ? blocker.stop() : blocker.start()
        } label: {
            Text(
                blocker.isBlocking
                    ? String(localized: "cleaning.button.stop", defaultValue: "Stop Cleaning Mode")
                    : String(localized: "cleaning.button.start", defaultValue: "Start Cleaning Mode")
            )
            .font(.headline)
            .frame(width: 196, height: 40)
            .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .glassEffect(
            blocker.isBlocking
                ? .regular.tint(.red).interactive()
                : .regular.tint(.accentColor).interactive(),
            in: .capsule
        )
    }

    private var permissionPrompt: some View {
        VStack(spacing: 12) {
            Text(
                String(
                    localized: "permission.prompt",
                    defaultValue: "Accessibility permission is required to intercept keyboard input."
                )
            )
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            Button {
                blocker.requestAccessibilityPermission()
            } label: {
                Text(String(localized: "permission.button.grant", defaultValue: "Grant Permission"))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .contentShape(.capsule)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: .capsule)
        }
    }
}

#Preview {
    ContentView(blocker: KeyboardBlocker())
}
