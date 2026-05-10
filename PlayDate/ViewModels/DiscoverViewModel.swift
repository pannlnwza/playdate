import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    var children: [Child]
    var matchedChild: Child?
    var showMatch: Bool = false

    private var rightSwipeCount: Int = 0
    private var lastSwipedChild: Child?

    init(children: [Child] = Child.mockChildren) {
        self.children = children
    }

    var canRewind: Bool { lastSwipedChild != nil }

    func swipe(_ direction: SwipeDirection) {
        guard let topChild = children.first else { return }
        children.removeFirst()
        lastSwipedChild = topChild

        if direction == .right {
            rightSwipeCount += 1
            if rightSwipeCount % 2 == 0 {
                matchedChild = topChild
                showMatch = true
            }
        }
    }

    func rewind() {
        guard let last = lastSwipedChild else { return }
        children.insert(last, at: 0)
        lastSwipedChild = nil
    }
}
