import Combine
import RealityKit

final class FurinAnimator {

    // 후우링 하나를 움직이는 데 필요한 정보를 보관합니다.
    private struct FurinAnimationInfo {
        let furin: Entity
        let paper: Entity
        let originalRotation: simd_quatf
        let randomOffset: Float
    }

    // 화면에 배치된 모든 후우링을 보관합니다.
    private var furins: [FurinAnimationInfo] = []

    // 애니메이션이 실행된 전체 시간입니다.
    private var animationTime: Float = 0

    // 매 프레임 업데이트를 계속 받을 수 있도록 구독을 보관합니다.
    private var animationSubscription: (any Cancellable)?

    // 새로 배치한 후우링을 애니메이션 목록에 등록합니다.
    func add(
        furin: Entity,
        paper: Entity
    ) {
        let animationInfo = FurinAnimationInfo(
            furin: furin,
            paper: paper,
            originalRotation: furin.orientation,
            randomOffset: Float.random(in: 0...(2 * .pi))
        )

        furins.append(animationInfo)
    }
}
