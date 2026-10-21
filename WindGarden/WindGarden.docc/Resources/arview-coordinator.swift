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
        private weak var arView: ARView?

        func start(using arView: ARView) {
            self.arView = arView
        }

        func handleTap(_ gesture: UITapGestureRecognizer) {
            // 다음 단계에서 탭 제스처와 연결합니다.
        }
    }
}
