import Foundation
import Observation

@Observable
final class DiscoverViewModel {
    var children: [Child]
    var currentUserHobbies: [String] = []
    var matchedChild: Child?
    var showMatch: Bool = false
    
    var minAge: Int = 0
    var maxAge: Int = 18
    var maxDistanceKm: Double = 50.0

    private var rightSwipeCount: Int = 0
    private var lastSwipedChild: Child?

    init(children: [Child] = Child.mockChildren, currentUserHobbies: [String] = []) {
        self.children = children
        self.currentUserHobbies = currentUserHobbies
    }

    var filteredChildren: [Child] {
        children.filter { child in
            // Age filter
            if child.age < minAge || child.age > maxAge { return false }
            
            // Distance filter
            if let distance = child.distanceKm, distance > maxDistanceKm { return false }
            
            return true
        }
    }

    var canRewind: Bool { lastSwipedChild != nil }

    func swipe(_ direction: SwipeDirection) {
        guard let topChild = filteredChildren.first else { return }
        
        // Find the index in the original array
        if let index = children.firstIndex(where: { $0.id == topChild.id }) {
            children.remove(at: index)
        }
        
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
    
    /// Calculates the number of shared hobbies between the current user and a child.
    func sharedHobbiesCount(for child: Child) -> Int {
        let childHobbies = Set(child.hobbies.map { $0.lowercased() })
        let userHobbies = Set(currentUserHobbies.map { $0.lowercased() })
        return childHobbies.intersection(userHobbies).count
    }
    
    /// Returns the names of shared hobbies.
    func sharedHobbies(for child: Child) -> [String] {
        let childHobbies = Set(child.hobbies.map { $0.lowercased() })
        let userHobbies = Set(currentUserHobbies.map { $0.lowercased() })
        return Array(childHobbies.intersection(userHobbies)).sorted()
    }
}
