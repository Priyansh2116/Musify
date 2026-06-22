import AppKit

// AppKit lifecycle (not the SwiftUI App scene) so we fully control a borderless
// floating panel and run as an accessory: no Dock icon, no app menu — just the
// widget and its status-bar item. Top-level code runs on the main thread, so we
// assume main-actor isolation to build the delegate and start the run loop.
MainActor.assumeIsolated {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.delegate = delegate
    app.setActivationPolicy(.accessory)
    app.run()
}
