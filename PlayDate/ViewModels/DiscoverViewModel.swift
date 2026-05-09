import Foundation
import Observation

enum SwipeDirection {
    case left, right
}

@Observable
final class DiscoverViewModel {
    var children: [Child]
    var matchedChild: Child?
    var showMatch: Bool = false
    private var rightSwipeCount: Int = 0

    init(children: [Child] = Child.mockChildren) {
        self.children = children
    }

    func swipe(_ direction: SwipeDirection) {
        guard let topChild = children.first else { return }
        children.removeFirst()

        if direction == .right {
            rightSwipeCount += 1
            if rightSwipeCount % 2 == 0 {
                matchedChild = topChild
                showMatch = true
            }
        }
    }
}
