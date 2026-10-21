//
//  ARViewContainer.swift
//  WindGarden
//
//  Created by unsistty on 8/4/26.
//

import ARKit
import RealityKit
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(
            frame: .zero,
            cameraMode: .ar,
            automaticallyConfigureSession: false
        )

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)

        // 사용자가 수직면을 찾도록 안내합니다.
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .verticalPlane
        coachingOverlay.activatesAutomatically = true
        coachingOverlay.frame = arView.bounds
        coachingOverlay.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight
        ]

        arView.addSubview(coachingOverlay)

        // 화면을 터치하면 Coordinator의 handleTap 메서드를 실행합니다.
        let tapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTap(_:))
        )
        arView.addGestureRecognizer(tapGesture)
        context.coordinator.start(using: arView)

        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {}

    final class Coordinator: NSObject {
        private let placementController = FurinPlacementController()

        func start(using arView: ARView) {
            placementController.start(using: arView)
        }

        @objc
        func handleTap(_ gesture: UITapGestureRecognizer) {
            placementController.handleTap(gesture)
        }
    }

    private final class FurinPlacementController {
        // 후우링 애니메이션을 관리합니다.
        private let furinAnimator = FurinAnimator()

        private weak var arView: ARView?

        func start(using arView: ARView) {
            self.arView = arView
        }

        func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView else {
                return
            }

            let touchPoint = gesture.location(in: arView)

            guard let raycastResult = findVerticalSurface(
                at: touchPoint,
                in: arView
            ) else {
                UINotificationFeedbackGenerator()
                    .notificationOccurred(.error)
                return
            }

            var hangingPosition = Transform(
                matrix: raycastResult.worldTransform
            ).translation

            // 찾은 면이 창문이면 창문의 가장 높은 위치를 사용합니다.
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

            // 계산한 위치에 후우링을 추가합니다.
            addFurin(
                at: hangingPosition,
                to: arView
            )
        }

        private func findVerticalSurface(
            at touchPoint: CGPoint,
            in arView: ARView
        ) -> ARRaycastResult? {
            let recognizedSurfaces = arView.raycast(
                from: touchPoint,
                allowing: .existingPlaneGeometry,
                alignment: .vertical
            )

            // 1. 창문으로 분류된 면을 우선 사용합니다.
            if let window = recognizedSurfaces.first(where: {
                ($0.anchor as? ARPlaneAnchor)?.classification == .window
            }) {
                return window
            }

            // 2. 창문이 아니더라도 인식된 수직면을 사용합니다.
            if let verticalSurface = recognizedSurfaces.first {
                return verticalSurface
            }

            // 3. 정확한 평면이 없다면 추정 수직면을 사용합니다.
            return arView.raycast(
                from: touchPoint,
                allowing: .estimatedPlane,
                alignment: .vertical
            ).first
        }

        private func findTopY(of window: ARPlaneAnchor) -> Float? {
            window.geometry.vertices
                .map { (window.transform * SIMD4<Float>($0, 1)).y }
                .max()
        }

        // MARK: - 후우링 배치하기

        private func addFurin(
            at position: SIMD3<Float>,
            to arView: ARView
        ) {
            // 계산한 현실 위치에 기준점을 만듭니다.
            let anchor = AnchorEntity(world: position)

            // FurinFactory에서 완성한 후우링을 가져옵니다.
            let parts = FurinFactory.make()

            // 후우링을 현실 위치의 기준점에 연결합니다.
            anchor.addChild(parts.furin)

            // 기준점을 AR 화면에 추가합니다.
            arView.scene.addAnchor(anchor)

            // 새로 배치한 후우링을 애니메이션 목록에 등록합니다.
            furinAnimator.add(
                furin: parts.furin,
                paper: parts.paper
            )
        }
    }
}
