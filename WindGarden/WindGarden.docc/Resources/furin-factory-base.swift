import RealityKit
import UIKit

struct FurinFactory {

    static func make() -> (furin: Entity, paper: Entity) {
        let furin = Entity()
        let paper = Entity()

        return (furin, paper)
    }
}
