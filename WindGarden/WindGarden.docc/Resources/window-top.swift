var hangingPosition = SIMD3<Float>(column.x, column.y, column.z)

if let window = result.anchor as? ARPlaneAnchor,
   window.classification == .window,
   let topY = findTopY(of: window) {
    hangingPosition.y = topY
}

let cameraPosition = arView.cameraTransform.translation
var cameraDirection = cameraPosition - hangingPosition
cameraDirection.y = 0

if simd_length(cameraDirection) > 0.01 {
    cameraDirection = simd_normalize(cameraDirection)
    hangingPosition += cameraDirection * 0.025
}

private func findTopY(of window: ARPlaneAnchor) -> Float? {
    let vertices = window.geometry.vertices
    guard !vertices.isEmpty else { return nil }

    return vertices.map { vertex in
        let localPoint = SIMD4<Float>(vertex.x, vertex.y, vertex.z, 1)
        return (window.transform * localPoint).y
    }.max()
}

