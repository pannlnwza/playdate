import XCTest
@testable import PlayDate

class DiscoverViewModelNewTests: XCTestCase {
    
    var viewModel: DiscoverViewModel!
    
    override func setUp() {
        super.setUp()
        let children = [
            Child(id: "1", parentId: "p1", name: "Alice", age: 3, hobbies: ["Lego", "Painting"], distanceKm: 5.0),
            Child(id: "2", parentId: "p2", name: "Bob", age: 7, hobbies: ["Soccer", "Lego"], distanceKm: 15.0),
            Child(id: "3", parentId: "p3", name: "Charlie", age: 12, hobbies: ["Gaming", "Robotics"], distanceKm: 60.0)
        ]
        viewModel = DiscoverViewModel(children: children, currentUserHobbies: ["Lego", "Chess"])
    }
    
    func testAgeFiltering() {
        viewModel.minAge = 2
        viewModel.maxAge = 5
        XCTAssertEqual(viewModel.filteredChildren.count, 1)
        XCTAssertEqual(viewModel.filteredChildren.first?.name, "Alice")
    }
    
    func testDistanceFiltering() {
        viewModel.maxDistanceKm = 20.0
        XCTAssertEqual(viewModel.filteredChildren.count, 2)
        XCTAssertFalse(viewModel.filteredChildren.contains { $0.name == "Charlie" })
    }
    
    func testSharedHobbiesCount() {
        let alice = viewModel.children[0]
        let bob = viewModel.children[1]
        let charlie = viewModel.children[2]
        
        XCTAssertEqual(viewModel.sharedHobbiesCount(for: alice), 1) // Lego
        XCTAssertEqual(viewModel.sharedHobbiesCount(for: bob), 1)   // Lego
        XCTAssertEqual(viewModel.sharedHobbiesCount(for: charlie), 0)
    }
    
    func testSharedHobbiesList() {
        let alice = viewModel.children[0]
        XCTAssertEqual(viewModel.sharedHobbies(for: alice), ["lego"])
    }
    
    func testSwipeRemovesFromFilteredAndOriginal() {
        viewModel.maxDistanceKm = 20.0 // Charlie is filtered out
        XCTAssertEqual(viewModel.filteredChildren.count, 2)
        
        let alice = viewModel.filteredChildren.first!
        viewModel.swipe(.left)
        
        XCTAssertEqual(viewModel.children.count, 2)
        XCTAssertFalse(viewModel.children.contains { $0.id == alice.id })
    }
}
