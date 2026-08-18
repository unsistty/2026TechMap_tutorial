private func makeFurin() -> (furin: Entity, paper: Entity) {
    let furin = Entity()

    let blue = SimpleMaterial(color: .systemBlue, roughness: 0.5, isMetallic: false)
    let glass = SimpleMaterial(
        color: UIColor(red: 0.65, green: 0.9, blue: 1, alpha: 0.32),
        roughness: 0.1,
        isMetallic: false
    )
    let orange = SimpleMaterial(color: .systemOrange, roughness: 0.5, isMetallic: false)
    let paperColor = SimpleMaterial(
        color: UIColor(red: 0.88, green: 0.95, blue: 1, alpha: 0.96),
        roughness: 0.8,
        isMetallic: false
    )

    let topString = ModelEntity(
        mesh: .generateCylinder(height: 0.10, radius: 0.002),
        materials: [blue]
    )
    topString.position.y = -0.05

    let glassBell = ModelEntity(
        mesh: .generateSphere(radius: 0.066),
        materials: [glass]
    )
    glassBell.position.y = -0.17
    glassBell.scale = [1, 0.9, 1]

    let innerString = ModelEntity(
        mesh: .generateCylinder(height: 0.15, radius: 0.002),
        materials: [blue]
    )
    innerString.position.y = -0.24

    let clapper = ModelEntity(
        mesh: .generateSphere(radius: 0.012),
        materials: [orange]
    )
    clapper.position.y = -0.29

    let paper = Entity()
    paper.position.y = -0.43
    let paperShape = ModelEntity(
        mesh: .generateBox(width: 0.062, height: 0.17, depth: 0.003),
        materials: [paperColor]
    )
    paper.addChild(paperShape)

    furin.addChild(topString)
    furin.addChild(glassBell)
    furin.addChild(innerString)
    furin.addChild(clapper)
    furin.addChild(paper)
    return (furin, paper)
}

