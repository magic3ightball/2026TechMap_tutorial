import ARKit
import RealityKit

@MainActor
final class ExcavationWall {
    let root = Entity()

    private let cover = ModelEntity()
    private let artifact = ModelEntity(
        mesh: .generateSphere(radius: 0.08),
        materials: [SimpleMaterial(color: .orange, isMetallic: false)]
    )

    private var brushCount = 0
    private var lastBrushTime = Date.distantPast
    private let requiredBrushCount = 6

    init(anchor: PlaneAnchor) async throws {
        configure(id: anchor.id)
        try await update(using: anchor)
    }

    /// Creates a wall in front of the person for Simulator,
    /// where plane detection isn't available.
    init(practiceWallID id: UUID) {
        configure(id: id)
        applyCover(mesh: .generatePlane(width: 1.2, height: 0.8))
        // Place it to the left so it doesn't cover the app window.
        root.position = [-1.3, 1.4, -2]
    }

    func update(using anchor: PlaneAnchor) async throws {
        let mesh = try await MeshResource(from: anchor)
        applyCover(mesh: mesh)
        root.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }

    func brush() {
        guard cover.isEnabled else {
            return
        }

        let now = Date.now
        guard now.timeIntervalSince(lastBrushTime) >= 0.25 else {
            return
        }
        lastBrushTime = now

        brushCount += 1
        guard brushCount >= requiredBrushCount else {
            // Fade the cover a little on every brush so progress is visible.
            let progress = Float(brushCount) / Float(requiredBrushCount)
            cover.components.set(OpacityComponent(opacity: 1 - progress * 0.7))
            return
        }

        cover.isEnabled = false
        artifact.isEnabled = true
    }

    private func configure(id: UUID) {
        root.addChild(artifact)
        root.addChild(cover)

        // This placeholder stands in for a fossil asset in the final experience.
        artifact.position = [0, 0, 0.02]
        artifact.isEnabled = false

        cover.name = id.uuidString
        cover.components.set(InputTargetComponent())
    }

    private func applyCover(mesh: MeshResource) {
        let material = SimpleMaterial(color: .brown, isMetallic: false)
        cover.model = ModelComponent(mesh: mesh, materials: [material])
        cover.generateCollisionShapes(recursive: false)
    }
}
