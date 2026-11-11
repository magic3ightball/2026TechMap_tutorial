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
        .gesture(
            DragGesture(minimumDistance: 0)
                .targetedToAnyEntity()
                .onChanged { value in
                    // Convert the touch to scene space so dust appears at the hand.
                    let point = value.convert(value.location3D, from: .local, to: .scene)
                    tracker.brush(entity: value.entity, at: point)
                }
        )
    }
}
