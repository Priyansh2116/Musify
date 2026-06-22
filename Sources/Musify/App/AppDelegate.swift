import AppKit
import Combine

/// Wires everything together: starts polling, shows the panel, and installs a
/// status-bar menu (the app runs as an accessory — no Dock icon, no main menu).
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let store = PlayerStore()
    private let settings = WidgetSettings()
    private var panel: PanelController!
    private var statusItem: NSStatusItem!
    private var bag = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Single instance only — if another copy is already running, bow out so we
        // don't end up with duplicate menu-bar icons / windows.
        let mine = Bundle.main.bundleIdentifier ?? "com.musify.app"
        if NSRunningApplication.runningApplications(withBundleIdentifier: mine).count > 1 {
            NSApp.terminate(nil)
            return
        }

        panel = PanelController(store: store, settings: settings)
        panel.show()
        store.start()

        setupStatusItem()

        // Rebuild the menu whenever settings change so checkmarks stay accurate.
        settings.objectWillChange
            .sink { [weak self] in
                DispatchQueue.main.async { self?.rebuildMenu() }
            }
            .store(in: &bag)
    }

    func applicationWillTerminate(_ notification: Notification) {
        store.stop()
    }

    // MARK: Status bar

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "music.note",
                accessibilityDescription: "Musify"
            )
        }
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let header = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        for style in WidgetStyle.allCases {
            let item = NSMenuItem(
                title: "  " + style.title,
                action: #selector(selectStyle(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = style.rawValue
            item.state = (settings.style == style) ? .on : .off
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let onTop = NSMenuItem(title: "Always on Top", action: #selector(toggleOnTop), keyEquivalent: "")
        onTop.target = self
        onTop.state = settings.alwaysOnTop ? .on : .off
        menu.addItem(onTop)

        let transparent = NSMenuItem(title: "Transparent Background", action: #selector(toggleTransparent), keyEquivalent: "")
        transparent.target = self
        transparent.state = settings.transparentBackground ? .on : .off
        menu.addItem(transparent)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit Mini Player", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    // MARK: Actions

    @objc private func selectStyle(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let style = WidgetStyle(rawValue: raw) else { return }
        settings.style = style
    }

    @objc private func toggleOnTop() { settings.alwaysOnTop.toggle() }
    @objc private func toggleTransparent() { settings.transparentBackground.toggle() }
    @objc private func quit() { NSApp.terminate(nil) }
}
