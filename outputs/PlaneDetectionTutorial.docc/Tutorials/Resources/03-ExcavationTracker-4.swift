import ARKit
import Observation
import RealityKit

@MainActor
@Observable
final class ExcavationTracker {
    enum State: Equatable {
        case idle
        case requestingAuthorization
        case unsupported
        case authorizationDenied
        case scanning
        case practice
        case failed(String)
    }

    let rootEntity = Entity()
    private var session = ARKitSession()
    private var provider = PlaneDetectionProvider(alignments: [.vertical])
    private var walls: [UUID: ExcavationWall] = [:]
    private var assets: ExcavationAssets?

    private(set) var state: State = .idle

    var isImmersiveSpaceOpen: Bool {
        state != .idle
    }

    var statusMessage: String {
        switch state {
        case .idle:
            "발굴을 시작할 준비가 되었습니다."
        case .requestingAuthorization:
            "주변 환경 접근 권한을 확인하고 있습니다."
        case .unsupported:
            "이 기기에서는 평면 감지를 사용할 수 없습니다."
        case .authorizationDenied:
            "평면 감지를 사용하려면 주변 환경 접근 권한이 필요합니다."
        case .scanning:
            "벽을 천천히 바라본 뒤, 흙 표면을 문질러 화석을 찾으세요."
        case .practice:
            "시뮬레이터에서는 실제 벽 대신 연습용 벽을 표시합니다. 흙 표면을 문지르세요."
        case .failed(let message):
            "평면 감지를 시작하지 못했습니다: \(message)"
        }
    }

    func start() async {
        // Load the fossil, soil, and sound once, before the first wall appears.
        if assets == nil {
            do {
                assets = try await ExcavationAssets.load()
            } catch {
                state = .failed(error.localizedDescription)
                return
            }
        }

        #if targetEnvironment(simulator)
        showPracticeWall()
        #else
        await startPlaneDetection()
        #endif
    }

    private func startPlaneDetection() async {
        guard state != .scanning else {
            return
        }

        guard PlaneDetectionProvider.isSupported else {
            state = .unsupported
            return
        }

        // A stopped data provider can't run again, so each scan uses new instances.
        session = ARKitSession()
        provider = PlaneDetectionProvider(alignments: [.vertical])

        state = .requestingAuthorization
        let authorization = await session.requestAuthorization(
            for: PlaneDetectionProvider.requiredAuthorizations
        )
        guard authorization[.worldSensing] == .allowed else {
            state = .authorizationDenied
            return
        }

        do {
            try await session.run([provider])
            state = .scanning

            for await update in provider.anchorUpdates {
                await process(update)
            }
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func stop() {
        session.stop()
        for wall in walls.values {
            wall.root.removeFromParent()
        }
        walls.removeAll()
        state = .idle
    }

    func brush(entity: Entity, at scenePoint: SIMD3<Float>) {
        guard let anchorID = UUID(uuidString: entity.name) else {
            return
        }

        walls[anchorID]?.brush(at: scenePoint)
    }

    private func showPracticeWall() {
        guard walls.isEmpty, let assets else {
            return
        }

        let id = UUID()
        let wall = ExcavationWall(practiceWallID: id, assets: assets)
        walls[id] = wall
        rootEntity.addChild(wall.root)
        state = .practice
    }

    private func process(_ update: AnchorUpdate<PlaneAnchor>) async {
        let anchor = update.anchor

        // Doors and windows are vertical too, but they aren't dig sites.
        // A classification can change as ARKit learns more,
        // so check it on every update.
        if anchor.classification == .door || anchor.classification == .window {
            walls[anchor.id]?.root.removeFromParent()
            walls.removeValue(forKey: anchor.id)
            return
        }

        switch update.event {
        case .added:
            do {
                guard let assets else {
                    return
                }
                let wall = try await ExcavationWall(anchor: anchor, assets: assets)
                walls[anchor.id] = wall
                rootEntity.addChild(wall.root)
            } catch {
                state = .failed(error.localizedDescription)
            }

        case .updated:
            do {
                try await walls[anchor.id]?.update(using: anchor)
            } catch {
                state = .failed(error.localizedDescription)
            }

        case .removed:
            walls[anchor.id]?.root.removeFromParent()
            walls.removeValue(forKey: anchor.id)
        }
    }
}
