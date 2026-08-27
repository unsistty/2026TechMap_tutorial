private func addFurin(
    at position: SIMD3<Float>,
    facing cameraPosition: SIMD3<Float>,
    to arView: ARView
) {
    let anchor = AnchorEntity(world: position)
    let furinParts = makeFurin()
    let furin = furinParts.furin
    let paper = furinParts.paper

    let direction = cameraPosition - position
    let angle = atan2(direction.x, direction.z)
    furin.orientation = simd_quatf(angle: angle, axis: [0, 1, 0])

    anchor.addChild(furin)
    arView.scene.addAnchor(anchor)

    // 다음 Section의 애니메이션 등록에서 furin과 paper를 사용합니다.
    _ = paper
}
