import XCTest
@testable import PlayDate

class ModelTests: XCTestCase {
    
    func testParentAverageRating() {
        let reviews = [
            Review(reviewerId: "r1", rating: 5, comment: "Great!"),
            Review(reviewerId: "r2", rating: 3, comment: "Okay"),
            Review(reviewerId: "r3", rating: 4, comment: "Good")
        ]
        
        let parent = Parent(name: "Test Parent", email: "test@example.com", reviews: reviews)
        
        XCTAssertEqual(parent.averageRating, 4.0, accuracy: 0.001)
    }
    
    func testParentAverageRatingEmpty() {
        let parent = Parent(name: "Test Parent", email: "test@example.com", reviews: [])
        XCTAssertEqual(parent.averageRating, 0.0)
    }
    
    func testEventCategoryExpansion() {
        let categories = EventCategory.allCases
        XCTAssertTrue(categories.contains(.educational))
        XCTAssertTrue(categories.contains(.sensory))
    }
    
    func testEventRecurrenceInitialization() {
        let event = Event(title: "Recurring Event",
                          description: "Desc",
                          locationName: "Loc",
                          latitude: 0,
                          longitude: 0,
                          dateTime: Date(),
                          organizerId: "org",
                          isRecurring: true,
                          frequency: .weekly)
        
        XCTAssertTrue(event.isRecurring)
        XCTAssertEqual(event.frequency, .weekly)
    }
}
