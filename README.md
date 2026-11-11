# Plane Detection으로 만드는 벽 발굴 체험

visionOS에서 수직 평면을 감지하고, 감지된 벽을 흙으로 덮어 문지르면 암모나이트 화석이 드러나게 만드는 DocC 튜토리얼입니다.

## 튜토리얼 보기

[GitHub Pages에서 튜토리얼 열기](https://magic3ightball.github.io/2026TechMap_tutorial/tutorials/planeexcavation/)

## 구성

- `outputs/PlaneDetectionTutorial.docc`: DocC 튜토리얼 원본과 누적 Swift 코드
- `docs`: GitHub Pages 배포용 정적 DocC 사이트
- `theme/apple-docc.css`: Apple Develop in Swift 튜토리얼과 같은 DocC 기본 디자인에 GitHub Pages 보정, 한국어 줄바꿈, 웹폰트(Pretendard, D2Coding)를 더한 테마
- `scripts/build-docs.sh`: 로컬 미리보기와 GitHub Pages 결과물을 함께 생성하는 빌드 스크립트

## 문서 빌드

```sh
./scripts/build-docs.sh
```

테마는 Apple의 Develop in Swift 튜토리얼에서 측정한 Step 카드 색·모서리, 현재 단계 표시선, 제목 굵기, 내비게이션 색을 DocC 변수로 맞춥니다. DocC 원본과 Swift 코드에는 영향을 주지 않습니다.

## 학습 내용

1. visionOS Full Space와 world-sensing 사용 목적 구성
2. `PlaneDetectionProvider`를 이용한 수직 평면 감지
3. `PlaneAnchor`의 추가·변경·삭제 이벤트 처리
4. `PlaneAnchor.classification`으로 문과 창문 제외
5. RealityKit entity에 collision과 targeted drag gesture 연결
6. 흙 덮개를 문지를수록 옅어지며 화석이 드러나는 발굴 상호 작용 (흙먼지 입자, 긁는 소리 포함)
7. 시뮬레이터 연습용 벽으로 Vision Pro 없이 상호 작용 확인

## 요구사항

- Xcode 16 이상, visionOS 2.0 이상 deployment target
- 실제 환경의 평면 감지는 Apple Vision Pro 실기기가 필요합니다. 발굴 상호 작용은 visionOS 시뮬레이터의 연습용 벽으로도 확인할 수 있습니다.

## 에셋 출처

3장의 Project files(`PlaneExcavationAssets.zip`)에 포함된 에셋입니다.

- `Ammonite.usdz`: 이 튜토리얼을 위해 생성한 모델. 돌 텍스처는 [ambientCG Rock030](https://ambientcg.com/a/Rock030) (CC0)
- `SoilColor.jpg`: [ambientCG Ground109](https://ambientcg.com/a/Ground109) (CC0)
- `Scrape.wav`: 이 튜토리얼을 위해 합성한 소리
