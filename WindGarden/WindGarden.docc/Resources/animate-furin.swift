private struct FurinAnimationInfo {
    let furin: Entity
    let paper: Entity
    let originalRotation: simd_quatf
    let randomOffset: Float
}

private var furins: [FurinAnimationInfo] = []
private var animationTime: Float = 0
private var animationSubscription: (any Cancellable)?

func start(using arView: ARView) {
    self.arView = arView
    animationSubscription = arView.scene.subscribe(to: SceneEvents.Update.self) {
        [weak self] event in
        self?.animateFurins(deltaTime: Float(event.deltaTime))
    }
}

private func animateFurins(deltaTime: Float) {
    animationTime += deltaTime

    for info in furins {
        let bodyAngle = sin(animationTime * 1.35 + info.randomOffset) * 0.055
        info.furin.orientation = info.originalRotation
            * simd_quatf(angle: bodyAngle, axis: [0, 0, 1])

        let paperAngle = sin(animationTime * 2.1 + info.randomOffset) * 0.24
        info.paper.orientation = simd_quatf(angle: paperAngle, axis: [0, 1, 0])
    }
}

