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

        // 반투명한 유리 종을 만듭니다.
        let glassBell = ModelEntity(
            mesh: .generateSphere(radius: 0.066),
            materials: [glass]
        )

        // 위쪽 줄 아래에 놓고, 종처럼 보이도록 세로 크기를 줄입니다.
        glassBell.position.y = -0.17
        glassBell.scale = [1, 0.9, 1]

        // 유리 종을 후우링에 넣습니다.
        furin.addChild(glassBell)

        // 유리 종 안쪽에서 아래로 이어지는 줄을 만듭니다.
        let innerString = ModelEntity(
            mesh: .generateCylinder(
                height: 0.20,
                radius: 0.002
            ),
            materials: [blue]
        )

        // 줄을 유리 종 안쪽에서 아래로 내려오도록 배치합니다.
        innerString.position.y = -0.26

        // 안쪽 줄을 후우링에 넣습니다.
        furin.addChild(innerString)

        // 유리 종을 두드리는 작은 추를 만듭니다.
        let clapper = ModelEntity(
            mesh: .generateSphere(radius: 0.012),
            materials: [orange]
        )

        // 추를 유리 종 아래쪽에 배치합니다.
        clapper.position.y = -0.29

        // 추를 후우링에 넣습니다.
        furin.addChild(clapper)

        // 종이 소원지의 위치를 정합니다.
        paper.position.y = -0.43

        // 얇은 상자 모양으로 종이를 만듭니다.
        let paperShape = ModelEntity(
            mesh: .generateBox(
                width: 0.062,
                height: 0.17,
                depth: 0.003
            ),
            materials: [paperColor]
        )

        // 종이 모양을 paper 객체에 넣습니다.
        paper.addChild(paperShape)

        // 완성한 종이 소원지를 후우링에 넣습니다.
        furin.addChild(paper)

        return FurinParts(furin: furin, paper: paper)
    }
}
