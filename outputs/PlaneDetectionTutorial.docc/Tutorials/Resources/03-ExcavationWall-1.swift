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

    init(anchor: PlaneAnchor) async throws {
        configure(id: anchor.id)
        try await update(using: anchor)
    }

    func update(using anchor: PlaneAnchor) async throws {
        let mesh = try await MeshResource(from: anchor)
        applyCover(mesh: mesh)
        root.transform = Transform(matrix: anchor.originFromAnchorTransform)
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
