// ARViewContainer 구조체의 첫 줄 안에 추가합니다.
func makeCoordinator() -> Coordinator {
    Coordinator()
}

// makeUIView(context:)의 return arView 바로 앞에 추가합니다.
let tapGesture = UITapGestureRecognizer(
    target: context.coordinator,
    action: #selector(Coordinator.handleTap(_:))
)
arView.addGestureRecognizer(tapGesture)
context.coordinator.start(using: arView)

// ARViewContainer 구조체 안에서 updateUIView 다음에 추가합니다.
final class Coordinator: NSObject {
    private weak var arView: ARView?

    func start(using arView: ARView) {
        self.arView = arView
    }

    @objc
    func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let arView else { return }
        let touchPoint = gesture.location(in: arView)

        guard let result = findVerticalSurface(at: touchPoint, in: arView) else {
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        let column = result.worldTransform.columns.3
        let position = SIMD3<Float>(column.x, column.y, column.z)
        // 다음 단계에서 이 위치에 후우링을 추가합니다.
        print("배치할 월드 좌표:", position)
    }

    private func findVerticalSurface(
        at touchPoint: CGPoint,
        in arView: ARView
    ) -> ARRaycastResult? {
        let recognized = arView.raycast(
            from: touchPoint,
            allowing: .existingPlaneGeometry,
            alignment: .vertical
        )

        if let window = recognized.first(where: {
            ($0.anchor as? ARPlaneAnchor)?.classification == .window
        }) {
            return window
        }

        if let verticalPlane = recognized.first {
            return verticalPlane
        }

        return arView.raycast(
            from: touchPoint,
            allowing: .estimatedPlane,
            alignment: .vertical
        ).first
    }
}
