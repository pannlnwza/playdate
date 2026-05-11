import XCTest
@testable import PlayDate

class EventsViewModelTests: XCTestCase {
    
    var viewModel: EventsViewModel!
    
    override func setUp() {
        super.setUp()
        let events = [
            Event(id: "1", title: "Morning Park", description: "Fun", locationName: "Central Park", latitude: 0, longitude: 0, dateTime: Date().addingTimeInterval(3600), organizerId: "o1", category: .outdoors, attendingFamilyCount: 5),
            Event(id: "2", title: "Afternoon Library", description: "Books", locationName: "City Library", latitude: 0, longitude: 0, dateTime: Date().addingTimeInterval(7200), organizerId: "o2", category: .educational, attendingFamilyCount: 10),
            Event(id: "3", title: "Featured Event", description: "Cool", locationName: "Plaza", latitude: 0, longitude: 0, dateTime: Date().addingTimeInterval(100), organizerId: "o3", category: .social, attendingFamilyCount: 2, isFeatured: true)
        ]
        viewModel = EventsViewModel(events: events)
    }
    
    func testUpcomingEventsExcludesFeatured() {
        XCTAssertEqual(viewModel.upcomingEvents.count, 2)
        XCTAssertFalse(viewModel.upcomingEvents.contains { $0.id == "3" })
    }
    
    func testFilteringByCategory() {
        viewModel.selectedCategories = [.outdoors]
        XCTAssertEqual(viewModel.upcomingEvents.count, 1)
        XCTAssertEqual(viewModel.upcomingEvents.first?.id, "1")
    }
    
    func testFilteringByMultipleCategories() {
        viewModel.selectedCategories = [.outdoors, .educational]
        XCTAssertEqual(viewModel.upcomingEvents.count, 2)
    }
    
    func testFilteringByDateRange() {
        let now = Date()
        viewModel.startDate = now.addingTimeInterval(5000)
        XCTAssertEqual(viewModel.upcomingEvents.count, 1)
        XCTAssertEqual(viewModel.upcomingEvents.first?.id, "2")
    }
    
    func testSortingByParticipantCount() {
        viewModel.sortOption = .participantCount
        XCTAssertEqual(viewModel.upcomingEvents.first?.id, "2") // 10 participants
        XCTAssertEqual(viewModel.upcomingEvents.last?.id, "1")  // 5 participants
    }
    
    func testClearFilters() {
        viewModel.selectedCategories = [.outdoors]
        viewModel.searchText = "Morning"
        viewModel.clearFilters()
        
        XCTAssertTrue(viewModel.selectedCategories.isEmpty)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertNil(viewModel.startDate)
    }
}
