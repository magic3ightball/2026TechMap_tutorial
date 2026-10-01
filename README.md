# Plane Detection으로 만드는 벽 발굴 체험

visionOS에서 수직 평면을 감지하고, 감지된 벽에 RealityKit 발굴 surface를 배치하는 DocC 튜토리얼입니다.

## 튜토리얼 보기

[GitHub Pages에서 튜토리얼 열기](https://magic3ightball.github.io/2026TechMap_tutorial/tutorials/planeexcavation/)

## 구성

- `outputs/PlaneDetectionTutorial.docc`: DocC 튜토리얼 원본과 누적 Swift 코드
- `docs`: GitHub Pages 배포용 정적 DocC 사이트
- `theme/cloudscape-docc.css`: Cloudscape 디자인 토큰과 패턴을 적용한 DocC 테마
- `scripts/build-docs.sh`: 로컬 미리보기와 GitHub Pages 결과물을 함께 생성하는 빌드 스크립트

## 문서 빌드

```sh
./scripts/build-docs.sh
```

테마는 Cloudscape의 표준 앱 레이아웃, 콘텐츠 레이아웃, 색상·간격·포커스 원칙을 DocC의 생성된 마크업에 맞게 적용합니다. DocC 원본과 Swift 코드에는 영향을 주지 않습니다.

## 학습 내용

1. visionOS Full Space와 world-sensing 사용 목적 구성
2. `PlaneDetectionProvider`를 이용한 수직 평면 감지
3. `PlaneAnchor`의 추가·변경·삭제 이벤트 처리
4. RealityKit entity에 collision과 targeted drag gesture 연결
5. 발굴 surface를 문질러 점점 옅어지는 cover 아래의 artifact placeholder 표시
6. 시뮬레이터 연습용 벽으로 Vision Pro 없이 상호 작용 확인

실제 환경의 평면 감지는 Apple Vision Pro에서 테스트해야 합니다. 발굴 상호 작용은 시뮬레이터의 연습용 벽으로도 확인할 수 있습니다.
