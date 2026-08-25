import SwiftUI

struct ContentView: View {
    @Environment(ExcavationTracker.self) private var tracker
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace

    @State private var launchMessage: String?
    @State private var isOpeningImmersiveSpace = false

    var body: some View {
        VStack {
            Text("벽 발굴 체험")
                .font(.title)

            Text("수직 벽을 스캔한 뒤 표면을 문질러 숨겨진 화석을 찾습니다.")
                .multilineTextAlignment(.center)

            Button("발굴 시작", action: openExcavationSpace)
                .buttonStyle(.borderedProminent)
                .disabled(isOpeningImmersiveSpace)

            if isOpeningImmersiveSpace {
                ProgressView("공간을 여는 중")
            }

            Text(launchMessage ?? tracker.statusMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel("앱 상태: \(launchMessage ?? tracker.statusMessage)")
        }
        .padding()
    }

    private func openExcavationSpace() {
        isOpeningImmersiveSpace = true
        launchMessage = nil

        Task {
            let result = await openImmersiveSpace(id: "ExcavationSpace")
            isOpeningImmersiveSpace = false

            switch result {
            case .opened:
                break
            case .userCancelled:
                launchMessage = "발굴 공간 열기를 취소했습니다."
            case .error:
                launchMessage = "발굴 공간을 열 수 없습니다. 잠시 후 다시 시도하세요."
            @unknown default:
                launchMessage = "알 수 없는 이유로 발굴 공간을 열 수 없습니다."
            }
        }
    }
}
