import SwiftUI

/// A thin, scrubbable progress bar that advances smoothly between polls via a
/// TimelineView. Optionally shows elapsed / remaining time beneath it.
struct ProgressBarView: View {
    @ObservedObject var store: PlayerStore
    var showTimes: Bool = true

    @State private var dragFraction: Double?

    var body: some View {
        VStack(spacing: 6) {
            TimelineView(.periodic(from: .now, by: 1.0 / 30.0)) { _ in
                let fraction = dragFraction ?? store.fraction
                GeometryReader { geo in
                    let w = geo.size.width
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.primary.opacity(0.12))
                        Capsule()
                            .fill(Color.primary.opacity(0.55))
                            .frame(width: max(0, w * fraction))
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { dragFraction = min(1, max(0, $0.location.x / w)) }
                            .onEnded {
                                let f = min(1, max(0, $0.location.x / w))
                                store.seek(toFraction: f)
                                dragFraction = nil
                            }
                    )
                }
                .frame(height: 4)

                if showTimes {
                    HStack {
                        Text(Self.clock(store.now.duration * (dragFraction ?? store.fraction)))
                        Spacer()
                        Text("-" + Self.clock(store.now.duration * (1 - (dragFraction ?? store.fraction))))
                    }
                    .font(Theme.time())
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    static func clock(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds.rounded())
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
