import RealityKit
import SwiftUI

struct ImmersiveView: View {
    @Environment(ExcavationTracker.self) private var tracker

    var body: some View {
        RealityView { content in
            content.add(tracker.rootEntity)
        }
        .task {
            await tracker.start()
        }
        .onDisappear {
            tracker.stop()
        }
    }
}
