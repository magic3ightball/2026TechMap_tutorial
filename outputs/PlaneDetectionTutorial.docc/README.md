# Plane Detection으로 만드는 벽 발굴 체험

이 DocC 카탈로그는 visionOS에서 수직 평면을 감지하고, 감지된 벽을 입력 가능한 RealityKit surface로 바꾸는 과정을 단계별로 설명합니다.

## 학습 결과

1. Full Space와 world-sensing 사용 목적을 구성합니다.
2. `PlaneDetectionProvider`로 수직 `PlaneAnchor`를 감지합니다.
3. `added`, `updated`, `removed` 이벤트에 맞춰 RealityKit entity를 관리합니다.
4. 감지된 평면에 collision과 targeted gesture를 연결합니다.
5. 표면을 문지르면 cover가 사라지고 artifact placeholder가 나타나는 결과를 만듭니다.

## 요구사항

- Xcode 16 이상
- visionOS 2.0 이상 deployment target
- 실제 환경의 평면 감지를 테스트할 Apple Vision Pro
- Swift와 SwiftUI 파일을 만들고 교체하는 기본적인 Xcode 사용 경험

## Xcode에서 사용하기

1. visionOS App 프로젝트를 만듭니다.
2. `PlaneDetectionTutorial.docc` 폴더를 Project navigator로 드래그합니다.
3. **Product > Build Documentation**을 선택합니다.
4. `Wall Excavation` 튜토리얼의 세 장을 순서대로 진행합니다.
5. 각 장의 마지막 성공 기준을 모두 확인한 뒤 다음 장으로 이동합니다.

`Tutorials/Resources`의 코드는 누적 스냅샷입니다. `01-` 파일로 앱 구조를 만든 뒤 `ExcavationTracker.swift`를 `02-`, `03-` 버전으로 차례로 교체합니다. `ImmersiveView.swift`는 마지막 장에서 `03-` 버전으로 교체합니다.

## 구현 범위

최종 장은 0.25초 간격으로 여섯 번의 drag update를 계산한 뒤 cover 전체를 숨깁니다. 손이 지나간 위치만 연속적으로 지우려면 texture alpha mask 또는 Metal shader를 별도로 구현해야 합니다. 이 단순화는 plane detection, anchor update, entity lifecycle과 입력 연결에 학습 범위를 집중하기 위한 것입니다.

## 공식 참고 자료

- [Placing content on detected planes](https://developer.apple.com/documentation/visionos/placing-content-on-detected-planes)
- [PlaneDetectionProvider](https://developer.apple.com/documentation/arkit/planedetectionprovider)
- [PlaneAnchor](https://developer.apple.com/documentation/arkit/planeanchor)
- [Setting up access to ARKit data](https://developer.apple.com/documentation/visionos/setting-up-access-to-arkit-data)
- [Responding to gestures on an entity](https://developer.apple.com/documentation/realitykit/responding-to-gestures-on-an-entity)
