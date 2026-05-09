import XCTest
@testable import PlayDate

@MainActor
class DiscoveryViewModelTests: XCTestCase {
    
    var viewModel: DiscoveryViewModel!
    var mockService: MockDataService!
    
    override func setUp() {
        super.setUp()
        mockService = MockDataService()
        viewModel = DiscoveryViewModel(dataService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchPotentialMatchesSuccess() async {
        let children = [Child(id: "1", parentId: "p1", name: "Kid 1", age: 5)]
        mockService.mockedChildren = children
        
        await viewModel.fetchPotentialMatches()
        
        XCTAssertEqual(viewModel.potentialMatches.count, 1)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSwipeRightUpdatesState() async {
        let child = Child(id: "1", parentId: "p1", name: "Kid 1", age: 5)
        viewModel.potentialMatches = [child]
        
        await viewModel.swipeRight(child: child)
        
        XCTAssertTrue(viewModel.potentialMatches.isEmpty)
        XCTAssertEqual(mockService.swipedChildId, "1")
        XCTAssertEqual(mockService.swipedDirection, .right)
    }
    
    func testSwipeLeftUpdatesState() async {
        let child = Child(id: "1", parentId: "p1", name: "Kid 1", age: 5)
        viewModel.potentialMatches = [child]
        
        await viewModel.swipeLeft(child: child)
        
        XCTAssertTrue(viewModel.potentialMatches.isEmpty)
        XCTAssertEqual(mockService.swipedChildId, "1")
        XCTAssertEqual(mockService.swipedDirection, .left)
    }
}
