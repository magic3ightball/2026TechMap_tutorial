import Observation
import RealityKit

@MainActor
@Observable
final class ExcavationTracker {
    enum State {
        case idle
        case immersiveSpaceOpen
    }

    let rootEntity = Entity()
    private(set) var state: State = .idle

    var isImmersiveSpaceOpen: Bool {
        state != .idle
    }

    var statusMessage: String {
        switch state {
        case .idle:
            "발굴을 시작할 준비가 되었습니다."
        case .immersiveSpaceOpen:
            "발굴 공간이 열렸습니다. 다음 장에서 벽 감지를 추가합니다."
        }
    }

    func start() async {
        state = .immersiveSpaceOpen
    }

    func stop() {
        state = .idle
    }
}
