import RealityKit
import UIKit

struct FurinParts {
    let furin: Entity
    let paper: Entity
}

enum FurinFactory {

    static func make() -> FurinParts {
        let furin = Entity()
        let paper = Entity()

        let blue = SimpleMaterial(
            color: .systemBlue,
            roughness: 0.5,
            isMetallic: false
        )

        return FurinParts(furin: furin, paper: paper)
    }
}
