import RealityKit

/// Loads the fossil, soil material, and scrape sound once
/// and shares them with every wall.
@MainActor
struct ExcavationAssets {
    let fossil: Entity
    let soil: PhysicallyBasedMaterial
    let scrape: AudioFileResource

    static func load() async throws -> ExcavationAssets {
        // Ammonite.usdz, SoilColor.jpg, and Scrape.wav must belong to the app target.
        let fossil = try await Entity(named: "Ammonite", in: nil)
        let soilTexture = try await TextureResource(named: "SoilColor.jpg", in: nil)
        let scrape = try await AudioFileResource(
            named: "Scrape.wav",
            in: nil,
            configuration: .init()
        )

        var soil = PhysicallyBasedMaterial()
        soil.baseColor = .init(texture: .init(soilTexture))
        soil.roughness = 0.95
        // Repeat the soil texture so a large wall doesn't look stretched.
        soil.textureCoordinateTransform = .init(scale: [3, 3])
        // Draw both sides, so the soil stays visible from either side of the plane.
        soil.faceCulling = .none

        return ExcavationAssets(fossil: fossil, soil: soil, scrape: scrape)
    }
}
