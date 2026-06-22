import AppKit

/// A borderless, transparent panel that sits on the desktop layer (behind your
/// app windows, like a widget), can be dragged from anywhere on its body, and
/// rides along to every Space and display. The level is set by PanelController.
final class FloatingPanel: NSPanel {
    init(size: CGSize) {
        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true

        // Drag from anywhere; don't steal focus from the app you're working in.
        isMovableByWindowBackground = true
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true

        // Stay put across Spaces and out of Mission Control / window cycling — the
        // way a desktop widget behaves.
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        // The panel itself draws nothing — the SwiftUI content owns the corners.
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
    }

    // Borderless windows reject key/main by default; allow it so controls work.
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
