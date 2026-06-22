import AppKit
import SwiftUI
import Combine

/// Owns the floating panel and keeps it reconciled with `WidgetSettings`:
/// resizing for the chosen style (preserving the top-left so it doesn't wander),
/// updating the window level, and re-hosting the SwiftUI tree.
@MainActor
final class PanelController {
    private let panel: FloatingPanel
    private let store: PlayerStore
    private let settings: WidgetSettings
    private var bag = Set<AnyCancellable>()

    init(store: PlayerStore, settings: WidgetSettings) {
        self.store = store
        self.settings = settings
        self.panel = FloatingPanel(size: settings.style.size)

        let root = RootView(store: store, settings: settings)
        let hosting = NSHostingView(rootView: root)
        hosting.frame = NSRect(origin: .zero, size: settings.style.size)
        panel.contentView = hosting

        observe()
        positionAtFirstLaunch()
    }

    func show() {
        panel.makeKeyAndOrderFront(nil)
    }

    private func observe() {
        settings.$style
            .removeDuplicates()
            .sink { [weak self] style in self?.resize(to: style) }
            .store(in: &bag)

        settings.$alwaysOnTop
            .sink { [weak self] on in
                guard let self else { return }
                // On top of apps when requested; otherwise pinned to the desktop
                // layer (behind your windows) so it behaves like a desktop widget.
                self.panel.level = on ? .floating : self.desktopLevel
            }
            .store(in: &bag)
    }

    /// One step below normal app windows: it stays behind whatever you're working
    /// in (widget-like), but still receives clicks/drags when the desktop is
    /// exposed. The true desktop level swallows mouse events, so we don't use it.
    private var desktopLevel: NSWindow.Level {
        NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
    }

    private func resize(to style: WidgetStyle) {
        guard let hosting = panel.contentView else { return }
        // Fixed size per style. The content is pinned to the top-left inside the
        // window, and for the transparent Minimal style the window is intentionally
        // taller than the content — the surplus is invisible, so nothing can clip.
        let newSize = style.size

        var frame = panel.frame
        // Anchor the top-left corner so resizing feels stable, not jumpy.
        let topLeft = NSPoint(x: frame.minX, y: frame.maxY)
        frame.size = newSize
        frame.origin = NSPoint(x: topLeft.x, y: topLeft.y - newSize.height)
        panel.setFrame(frame, display: true, animate: false)
        hosting.frame = NSRect(origin: .zero, size: newSize)
    }

    private func positionAtFirstLaunch() {
        guard let screen = NSScreen.main else { return }
        let v = screen.visibleFrame
        let size = panel.frame.size   // actual size after fitting
        // Lower-right by default — out of the way, near the menu-bar clock side.
        let origin = NSPoint(
            x: v.maxX - size.width - 24,
            y: v.minY + 24
        )
        panel.setFrameOrigin(origin)
    }
}
