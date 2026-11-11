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
    private var session = ARKitSession()
    private var provider = PlaneDetectionProvider(alignments: [.vertical])
    private var markers: [UUID: PlaneMarker] = [:]

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
            "벽을 천천히 바라보며 수직 평면을 찾으세요."
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
        for marker in markers.values {
            marker.root.removeFromParent()
        }
        markers.removeAll()
        state = .idle
    }

    private func process(_ update: AnchorUpdate<PlaneAnchor>) async {
        let anchor = update.anchor

        // Doors and windows are vertical too, but they aren't dig sites.
        // A classification can change as ARKit learns more,
        // so check it on every update.
        if anchor.classification == .door || anchor.classification == .window {
            markers[anchor.id]?.root.removeFromParent()
            markers.removeValue(forKey: anchor.id)
            return
        }

        switch update.event {
        case .added:
            do {
                let marker = try await PlaneMarker(anchor: anchor)
                markers[anchor.id] = marker
                rootEntity.addChild(marker.root)
            } catch {
                state = .failed(error.localizedDescription)
            }

        case .updated:
            do {
                try await markers[anchor.id]?.update(using: anchor)
            } catch {
                state = .failed(error.localizedDescription)
            }

        case .removed:
            markers[anchor.id]?.root.removeFromParent()
            markers.removeValue(forKey: anchor.id)
        }
    }
}
