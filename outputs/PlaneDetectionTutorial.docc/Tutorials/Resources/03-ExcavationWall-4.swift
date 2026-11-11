import ARKit
import RealityKit
import UIKit

@MainActor
final class ExcavationWall {
    let root = Entity()

    private let cover = ModelEntity()
    private let artifact: Entity
    private let dust = Entity()
    private let assets: ExcavationAssets

    private var brushCount = 0
    private var lastBrushTime = Date.distantPast
    private let requiredBrushCount = 6

    init(anchor: PlaneAnchor, assets: ExcavationAssets) async throws {
        self.assets = assets
        artifact = assets.fossil.clone(recursive: true)
        configure(id: anchor.id)
        try await update(using: anchor)
    }

    /// Creates a wall in front of the person for Simulator,
    /// where plane detection isn't available.
    init(practiceWallID id: UUID, assets: ExcavationAssets) {
        self.assets = assets
        artifact = assets.fossil.clone(recursive: true)
        configure(id: id)
        applyCover(bounds: BoundingBox(min: [-0.6, -0.4, 0], max: [0.6, 0.4, 0]))
        // Place it to the left so it doesn't cover the app window.
        root.position = [-1.3, 1.4, -2]
    }

    func update(using anchor: PlaneAnchor) async throws {
        // Use the detected plane's size and center to place a textured rectangle.
        let detected = try await MeshResource(from: anchor)
        applyCover(bounds: detected.bounds)
        root.transform = Transform(matrix: anchor.originFromAnchorTransform)
    }

    func brush(at scenePoint: SIMD3<Float>) {
        guard cover.isEnabled else {
            return
        }

        let now = Date.now
        guard now.timeIntervalSince(lastBrushTime) >= 0.25 else {
            return
        }
        lastBrushTime = now

        // Puff dust where the hand touched, and play the scrape sound from the wall.
        dust.setPosition(scenePoint, relativeTo: nil)
        if var emitter = dust.components[ParticleEmitterComponent.self] {
            emitter.burst()
            dust.components.set(emitter)
        }
        root.playAudio(assets.scrape)

        brushCount += 1
        guard brushCount >= requiredBrushCount else {
            // As the soil thins, the fossil behind it shows through.
            let progress = Float(brushCount) / Float(requiredBrushCount)
            cover.components.set(OpacityComponent(opacity: 1 - progress * 0.8))
            return
        }

        cover.isEnabled = false
    }

    private func configure(id: UUID) {
        root.addChild(artifact)
        root.addChild(cover)
        root.addChild(dust)

        cover.name = id.uuidString
        cover.components.set(InputTargetComponent())

        var emitter = ParticleEmitterComponent.Presets.impact
        emitter.isEmitting = false
        emitter.burstCount = 60
        emitter.speed = 0.2
        emitter.mainEmitter.color = .constant(
            .single(UIColor(red: 0.55, green: 0.42, blue: 0.28, alpha: 1))
        )
        dust.components.set(emitter)
    }

    private func applyCover(bounds: BoundingBox) {
        // A plane is thin along its normal,
        // so the smallest side of the bounds tells which way it faces.
        let size = bounds.extents
        let liesInXZ = size.y < size.z
        let mesh: MeshResource = liesInXZ
            ? .generatePlane(width: size.x, depth: size.z)
            : .generatePlane(width: size.x, height: size.y)
        let normal: SIMD3<Float> = liesInXZ ? [0, 1, 0] : [0, 0, 1]

        cover.model = ModelComponent(mesh: mesh, materials: [assets.soil])
        cover.position = bounds.center
        cover.generateCollisionShapes(recursive: false)

        // The fossil model faces +Z.
        // Turn it toward the plane's normal and set it just behind the soil.
        artifact.orientation = simd_quatf(
            angle: liesInXZ ? -.pi / 2 : 0,
            axis: [1, 0, 0]
        )
        artifact.scale = [2, 2, 2]
        artifact.position = bounds.center - normal * 0.02

        // Show the fossil only after the detected wall is larger than the fossil.
        artifact.isEnabled = size.x > 0.5 && max(size.y, size.z) > 0.4
    }
}
