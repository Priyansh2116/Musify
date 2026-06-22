import SwiftUI
import Combine

/// User-tunable widget state, driven from the status-bar menu. The panel observes
/// it to resize, re-level, and toggle translucency.
final class WidgetSettings: ObservableObject {
    @Published var style: WidgetStyle = .minimal
    @Published var alwaysOnTop: Bool = false   // false = sit on the desktop, like a widget
    @Published var transparentBackground: Bool = true
}
