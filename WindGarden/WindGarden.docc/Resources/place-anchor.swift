private func addFurin(
    at position: SIMD3<Float>,
    facing cameraPosition: SIMD3<Float>,
    to arView: ARView
) {
    let anchor = AnchorEntity(world: position)
    let parts = makeFurin()

    let direction = cameraPosition - position
    let angle = atan2(direction.x, direction.z)
    parts.furin.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])

    anchor.addChild(parts.furin)
    arView.scene.addAnchor(anchor)
}

