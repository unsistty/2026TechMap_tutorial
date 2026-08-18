func makeCoordinator() -> Coordinator {
    Coordinator()
}

// makeUIView(context:)에서 arView.session.run(configuration) 다음에 추가합니다.
let tapGesture = UITapGestureRecognizer(
    target: context.coordinator,
    action: #selector(Coordinator.handleTap(_:))
)
arView.addGestureRecognizer(tapGesture)

let guide = ARCoachingOverlayView()
guide.session = arView.session
guide.goal = .verticalPlane
guide.activatesAutomatically = true
guide.frame = arView.bounds
guide.autoresizingMask = [.flexibleWidth, .flexibleHeight]
arView.addSubview(guide)

context.coordinator.start(using: arView)

