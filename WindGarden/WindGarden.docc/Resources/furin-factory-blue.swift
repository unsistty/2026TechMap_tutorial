import RealityKit
import UIKit

struct FurinFactory {

    static func make() -> (furin: Entity, paper: Entity) {
        let furin = Entity()
        let paper = Entity()

        let blue = SimpleMaterial(
            color: .systemBlue,
            roughness: 0.5,
            isMetallic: false
        )

        return (furin, paper)
    }
}
