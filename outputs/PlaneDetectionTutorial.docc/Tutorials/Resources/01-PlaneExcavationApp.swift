import SwiftUI

@main
struct PlaneExcavationApp: App {
    @State private var tracker = ExcavationTracker()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(tracker)
        }

        ImmersiveSpace(id: "ExcavationSpace") {
            ImmersiveView()
                .environment(tracker)
        }
    }
}
