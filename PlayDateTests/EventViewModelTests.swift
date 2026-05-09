import XCTest
@testable import PlayDate

@MainActor
class EventViewModelTests: XCTestCase {
    
    var viewModel: EventViewModel!
    var mockService: MockDataService!
    let testUserId = "user123"
    
    override func setUp() {
        super.setUp()
        mockService = MockDataService()
        viewModel = EventViewModel(dataService: mockService, userId: testUserId)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchEventsSuccess() async {
        let events = [Event(id: "1", title: "Test Event", description: "Desc", locationName: "Park", latitude: 0, longitude: 0, dateTime: Date(), organizerId: "admin")]
        mockService.mockedEvents = events
        
        await viewModel.fetchEvents()
        
        XCTAssertEqual(viewModel.events.count, 1)
        XCTAssertEqual(viewModel.events.first?.title, "Test Event")
    }
    
    func testFilteringEvents() {
        let event1 = Event(id: "1", title: "Park Day", description: "Fun", locationName: "Park", latitude: 0, longitude: 0, dateTime: Date(), organizerId: "admin")
        let event2 = Event(id: "2", title: "Library", description: "Books", locationName: "Library", latitude: 0, longitude: 0, dateTime: Date(), organizerId: "admin")
        viewModel.events = [event1, event2]
        
        viewModel.searchQuery = "Park"
        XCTAssertEqual(viewModel.filteredEvents.count, 1)
        XCTAssertEqual(viewModel.filteredEvents.first?.id, "1")
        
        viewModel.searchQuery = "Books"
        XCTAssertEqual(viewModel.filteredEvents.count, 1)
        XCTAssertEqual(viewModel.filteredEvents.first?.id, "2")
    }
    
    func testJoinEventSuccess() async {
        let event = Event(id: "1", title: "Park", description: "Fun", locationName: "Park", latitude: 0, longitude: 0, dateTime: Date(), organizerId: "admin")
        viewModel.events = [event]
        
        await viewModel.joinEvent(event)
        
        XCTAssertEqual(mockService.joinedEventId, "1")
        XCTAssertTrue(viewModel.events.first?.participantIds.contains(testUserId) ?? false)
    }
    
    func testCreateEventSuccess() async {
        let date = Date()
        await viewModel.createEvent(title: "New", description: "Desc", locationName: "Home", latitude: 1, longitude: 1, dateTime: date)
        
        XCTAssertNotNil(mockService.createdEvent)
        XCTAssertEqual(mockService.createdEvent?.title, "New")
        XCTAssertEqual(viewModel.events.count, 1)
    }
}
