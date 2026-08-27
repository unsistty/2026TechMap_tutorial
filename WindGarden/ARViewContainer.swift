//
//  ARViewContainer.swift
//  WindGarden
//
//  Created by unsistty on 8/4/26.
//

import ARKit
import Combine
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {

    // SwiftUI와 AR 화면 사이에서 탭 동작을 처리할 객체를 만듭니다.
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    // AR 화면을 처음 한 번 만드는 곳입니다.
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )

        // 1. 바닥이 아니라 창문과 창틀 같은 수직면을 찾습니다.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)

        // 2. 화면을 터치하면 handleTap 함수가 실행됩니다.
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)

        // 3. 사용자가 수직면을 잘 찾을 수 있도록 ARKit 기본 안내를 보여줍니다.
        let guide = ARCoachingOverlayView()
        guide.session = arView.session
        guide.goal = .verticalPlane
        guide.activatesAutomatically = true
        guide.frame = arView.bounds
        guide.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.addSubview(guide)

        context.coordinator.start(using: arView)
        return arView
    }

    // SwiftUI 화면이 갱신될 때 호출됩니다. 지금은 바꿀 내용이 없습니다.
    func updateUIView(_ uiView: ARView, context: Context) {}

    final class Coordinator: NSObject {

        // 흔들어야 하는 후우링의 정보를 보관합니다.
        private struct FurinAnimationInfo {
            let furin: Entity
            let paper: Entity
            let originalRotation: simd_quatf
            let randomOffset: Float
        }

        private weak var arView: ARView?
        private var furins: [FurinAnimationInfo] = []
        private var animationTime: Float = 0

        // RealityKit이 매 프레임 알려 주는 업데이트를 계속 받기 위해 보관합니다.
        private var animationSubscription: (any Cancellable)?

        func start(using arView: ARView) {
            self.arView = arView

            animationSubscription = arView.scene.subscribe(
                to: SceneEvents.Update.self
            ) { [weak self] event in
                self?.animateFurins(deltaTime: Float(event.deltaTime))
            }
        }

        // MARK: - 사용자가 화면을 터치했을 때

        @objc
        func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView else { return }

            let touchPoint = gesture.location(in: arView)

            // 터치한 곳에 창문이나 수직면이 있는지 확인합니다.
            guard let raycastResult = findVerticalSurface(
                at: touchPoint,
                in: arView
            ) else {
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.error)
                return
            }

            let positionColumn = raycastResult.worldTransform.columns.3
            var hangingPosition = SIMD3<Float>(
                positionColumn.x,
                positionColumn.y,
                positionColumn.z
            )

            // ARKit이 이 면을 창문이라고 판단했다면 창문의 윗선에 매답니다.
            if let window = raycastResult.anchor as? ARPlaneAnchor,
               window.classification == .window,
               let topY = findTopY(of: window) {
                hangingPosition.y = topY
            }

            // 후우링이 창문 안에 묻혀 보이지 않게 카메라 쪽으로 조금 당깁니다.
            let cameraPosition = arView.cameraTransform.translation
            var cameraDirection = cameraPosition - hangingPosition
            cameraDirection.y = 0

            if simd_length(cameraDirection) > 0.01 {
                cameraDirection = simd_normalize(cameraDirection)
                hangingPosition += cameraDirection * 0.025
            }

            addFurin(
                at: hangingPosition,
                facing: cameraPosition,
                to: arView
            )

            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }

        // MARK: - 창문 찾기

        private func findVerticalSurface(
            at touchPoint: CGPoint,
            in arView: ARView
        ) -> ARRaycastResult? {
            // 먼저 ARKit이 이미 정확하게 인식한 수직면들을 찾습니다.
            let recognizedSurfaces = arView.raycast(
                from: touchPoint,
                allowing: .existingPlaneGeometry,
                alignment: .vertical
            )

            // 그중에서 창문으로 분류된 면을 가장 먼저 사용합니다.
            for result in recognizedSurfaces {
                if let plane = result.anchor as? ARPlaneAnchor,
                   plane.classification == .window {
                    return result
                }
            }

            // 창문 분류에 실패했어도 인식한 수직 창틀이 있으면 사용합니다.
            if let firstSurface = recognizedSurfaces.first {
                return firstSurface
            }

            // 아직 정확한 평면이 없으면 ARKit이 추정한 수직면을 사용합니다.
            return arView.raycast(
                from: touchPoint,
                allowing: .estimatedPlane,
                alignment: .vertical
            ).first
        }

        private func findTopY(of window: ARPlaneAnchor) -> Float? {
            let vertices = window.geometry.vertices
            guard !vertices.isEmpty else { return nil }

            var highestY: Float?

            // 창문 경계점 하나하나를 확인해서 가장 높은 Y 값을 찾습니다.
            for vertex in vertices {
                let localPoint = SIMD4<Float>(
                    vertex.x,
                    vertex.y,
                    vertex.z,
                    1
                )
                let worldPoint = window.transform * localPoint

                if let currentHighestY = highestY {
                    if worldPoint.y > currentHighestY {
                        highestY = worldPoint.y
                    }
                } else {
                    highestY = worldPoint.y
                }
            }

            return highestY
        }

        // MARK: - 후우링 배치하기

        private func addFurin(
            at position: SIMD3<Float>,
            facing cameraPosition: SIMD3<Float>,
            to arView: ARView
        ) {
            // AnchorEntity는 현실 공간의 매다는 위치를 기억합니다.
            let anchor = AnchorEntity(world: position)

            let furinParts = makeFurin()
            let furin = furinParts.furin
            let paper = furinParts.paper

            // 종이 소원지의 앞면이 사용자를 바라보게 합니다.
            let direction = cameraPosition - position
            let angle = atan2(direction.x, direction.z)
            furin.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])

            anchor.addChild(furin)
            arView.scene.addAnchor(anchor)

            let animationInfo = FurinAnimationInfo(
                furin: furin,
                paper: paper,
                originalRotation: furin.orientation,
                randomOffset: Float.random(in: 0...(2 * .pi))
            )
            furins.append(animationInfo)
        }

        // MARK: - 후우링 모양 만들기

        private func makeFurin() -> (furin: Entity, paper: Entity) {
            let furin = Entity()

            // 사용할 색을 먼저 준비합니다.
            let blue = SimpleMaterial(
                color: .systemBlue,
                roughness: 0.5,
                isMetallic: false
            )
            let glass = SimpleMaterial(
                color: UIColor(
                    red: 0.65,
                    green: 0.9,
                    blue: 1,
                    alpha: 0.32
                ),
                roughness: 0.1,
                isMetallic: false
            )
            let orange = SimpleMaterial(
                color: .systemOrange,
                roughness: 0.5,
                isMetallic: false
            )
            let paperColor = SimpleMaterial(
                color: UIColor(
                    red: 0.88,
                    green: 0.95,
                    blue: 1,
                    alpha: 0.96
                ),
                roughness: 0.8,
                isMetallic: false
            )

            // 1. 창틀에서 유리 종으로 이어지는 줄
            let topString = ModelEntity(
                mesh: .generateCylinder(height: 0.10, radius: 0.002),
                materials: [blue]
            )
            topString.position.y = -0.05

            // 2. 투명한 둥근 유리 종
            let glassBell = ModelEntity(
                mesh: .generateSphere(radius: 0.066),
                materials: [glass]
            )
            glassBell.position.y = -0.17
            glassBell.scale = [1, 0.9, 1]

            // 3. 유리 종 안쪽에서 아래로 이어지는 줄
            let innerString = ModelEntity(
                mesh: .generateCylinder(height: 0.20, radius: 0.002),
                materials: [blue]
            )
            innerString.position.y = -0.26

            // 4. 바람이 불면 유리 종을 치는 작은 추
            let clapper = ModelEntity(
                mesh: .generateSphere(radius: 0.012),
                materials: [orange]
            )
            clapper.position.y = -0.29

            // 5. 아래쪽 종이 소원지
            let paper = Entity()
            paper.position.y = -0.43

            let paperShape = ModelEntity(
                mesh: .generateBox(
                    width: 0.062,
                    height: 0.17,
                    depth: 0.003
                ),
                materials: [paperColor]
            )
            paper.addChild(paperShape)

            furin.addChild(topString)
            furin.addChild(glassBell)
            furin.addChild(innerString)
            furin.addChild(clapper)
            furin.addChild(paper)

            return (furin, paper)
        }

        // MARK: - 후우링 흔들기

        private func animateFurins(deltaTime: Float) {
            animationTime += deltaTime

            for info in furins {
                // sin 값은 -1과 1 사이를 반복해서 자연스러운 좌우 움직임을 만듭니다.
                let furinAngle = sin(
                    animationTime * 1.35 + info.randomOffset
                ) * 0.055

                info.furin.orientation = info.originalRotation
                    * simd_quatf(angle: furinAngle, axis: [0, 0, 1])

                let paperAngle = sin(
                    animationTime * 2.1 + info.randomOffset
                ) * 0.24

                info.paper.orientation = simd_quatf(
                    angle: paperAngle,
                    axis: [0, 1, 0]
                )
            }
        }
    }
}
