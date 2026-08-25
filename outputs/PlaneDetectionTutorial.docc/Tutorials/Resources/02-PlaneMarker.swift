import ARKit
import RealityKit

@MainActor
final class PlaneMarker {
    let root = Entity()
    private let model = ModelEntity()

    init(anchor: PlaneAnchor) async throws {
        root.addChild(model)
        try await update(using: anchor)
    }

    func update(using anchor: PlaneAnchor) async throws {
        let mesh = try await MeshResource(from: anchor)
        let material = UnlitMaterial(color: .cyan)
        model.model = ModelComponent(mesh: mesh, materials: [material])
        root.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }
}
