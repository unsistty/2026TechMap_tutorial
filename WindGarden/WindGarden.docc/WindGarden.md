# WindGarden

SwiftUI로 증강현실(AR) 앱을 만듭니다. 현실의 창문을 찾고, 그곳에 바람 따라 흔들리는 일본식 풍경인 후우링(風鈴)을 매답니다.

## 개요

이 DocC 문서는 앱을 처음 만드는 과정부터 차례로 설명합니다. 먼저 SwiftUI 화면에 RealityKit의 카메라 화면인 `ARView`를 넣습니다. 그다음 ARKit으로 창문이나 벽을 찾고, 직접 만든 후우링을 그 위치에 놓습니다. 외부 3D 모델 파일은 사용하지 않습니다. RealityKit이 제공하는 기본 3D 도형을 조립하고, `SceneEvents.Update`가 화면을 새로 그릴 때마다 흔들림을 만듭니다.

완성 프로젝트에서는 역할을 나눕니다. `ContentView.swift`는 AR 화면을 보여주고, `ARViewContainer.swift`의 `Coordinator`는 SwiftUI와 UIKit 사이에서 터치 이벤트를 전달합니다. `FurinPlacementController`는 현실 위치 탐색과 배치를 처리하고, `FurinFactory.swift`는 후우링 모양을 만들며, `FurinAnimator.swift`는 완성된 후우링을 흔듭니다.

> Important: Xcode의 가상 기기인 iOS 시뮬레이터에서는 카메라와 공간 인식 기능을 확인할 수 없습니다. ARKit을 지원하는 실제 iPhone이나 iPad에서 실행해야 합니다.

## 문서 목록

### 튜토리얼

- <doc:set-up-windgarden-ar>
- <doc:build-and-animate-furin>
