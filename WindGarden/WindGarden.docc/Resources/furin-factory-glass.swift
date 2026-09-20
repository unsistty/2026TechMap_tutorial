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

        let glass = SimpleMaterial(
            color: UIColor(
                red: 0.65,
                green: 0.9,
                blue: 1,
                alpha: 0.32
            ),
            roughness: 0.1,
            isMetallic: false
        )

        return FurinParts(furin: furin, paper: paper)
    }
}
