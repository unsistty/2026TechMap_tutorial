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

        let orange = SimpleMaterial(
            color: .systemOrange,
            roughness: 0.5,
            isMetallic: false
        )

        let paperColor = SimpleMaterial(
            color: UIColor(
                red: 0.88,
                green: 0.95,
                blue: 1,
                alpha: 0.96
            ),
            roughness: 0.8,
            isMetallic: false
        )

        // 창틀에서 유리 종까지 이어지는 위쪽 줄을 만듭니다.
        let topString = ModelEntity(
            mesh: .generateCylinder(
                height: 0.10,
                radius: 0.002
            ),
            materials: [blue]
        )

        // 부모 위치에서 아래쪽으로 줄을 내립니다.
        topString.position.y = -0.05

        // 완성한 줄을 후우링에 넣습니다.
        furin.addChild(topString)

        return FurinParts(furin: furin, paper: paper)
    }
}
