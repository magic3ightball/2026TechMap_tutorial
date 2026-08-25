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
        case failed(String)
    }

    let rootEntity = Entity()
    private let session = ARKitSession()
    private let provider = PlaneDetectionProvider(alignments: [.vertical])
    private var walls: [UUID: ExcavationWall] = [:]

    private(set) var state: State = .idle

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
            "벽을 천천히 바라본 뒤, 갈색 발굴 표면을 문지르세요."
        case .failed(let message):
            "평면 감지를 시작하지 못했습니다: \(message)"
        }
    }

    func start() async {
        guard state != .scanning else {
            return
        }

        guard PlaneDetectionProvider.isSupported else {
            state = .unsupported
            return
        }

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

    func brush(entity: Entity) {
        guard let anchorID = UUID(uuidString: entity.name) else {
            return
        }

        walls[anchorID]?.brush()
    }

    private func process(_ update: AnchorUpdate<PlaneAnchor>) async {
        let anchor = update.anchor

        switch update.event {
        case .added:
            do {
                let wall = try await ExcavationWall(anchor: anchor)
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
