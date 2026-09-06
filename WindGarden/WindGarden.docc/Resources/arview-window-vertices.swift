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

    func updateUIView(_ uiView: ARView, context: Context) {
    }

    final class Coordinator: NSObject {
        private weak var arView: ARView?

        func start(using arView: ARView) {
            self.arView = arView
        }

        @objc
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

            let positionColumn = raycastResult.worldTransform.columns.3
            let position = SIMD3<Float>(
                positionColumn.x,
                positionColumn.y,
                positionColumn.z
            )

            print("배치할 월드 좌표:", position)
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
            let vertices = window.geometry.vertices

            guard !vertices.isEmpty else {
                return nil
            }

            // 다음 단계에서 가장 높은 점을 찾아 반환합니다.
            return nil
        }
    }
}
