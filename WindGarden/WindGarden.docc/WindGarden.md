# WindGarden

현실의 창문에 바람 따라 흔들리는 일본식 풍경, 후우링(風鈴)을 매다는 SwiftUI 기반 AR 앱을 만듭니다.

## Overview

이 DocC 카탈로그는 SwiftUI 화면에 RealityKit의 `ARView`를 연결하고, ARKit이 감지한 창문 또는 수직면에 직접 만든 후우링을 배치하는 전 과정을 설명합니다. 외부 3D 모델은 사용하지 않습니다. `ModelEntity`와 기본 메시만 조합하고, `SceneEvents.Update`에서 사인 함수를 적용해 흔들림을 만듭니다.

완성 프로젝트의 핵심 파일은 앱 진입점인 `WindGardenApp.swift`, AR 화면과 SwiftUI 안내를 배치하는 `ContentView.swift`, AR 세션·탭·raycast·후우링 모델·애니메이션을 담당하는 `ARViewContainer.swift`입니다.

> Important: 카메라 영상, 월드 트래킹, 평면 감지는 iOS Simulator에서 동작하지 않습니다. ARKit을 지원하는 실제 iPhone 또는 iPad가 필요합니다.

## Topics

### 튜토리얼

- <doc:창문에-AR-후우링-매달기>
