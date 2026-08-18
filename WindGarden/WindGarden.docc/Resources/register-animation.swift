let animationInfo = FurinAnimationInfo(
    furin: furin,
    paper: paper,
    originalRotation: furin.orientation,
    randomOffset: Float.random(in: 0...(2 * .pi))
)
furins.append(animationInfo)

