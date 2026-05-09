import XCTest
@testable import PlayDate

class ModelTests: XCTestCase {
    
    func testParentCodable() throws {
        let parent = Parent(id: "1", name: "John Doe", email: "john@example.com", isVerified: true)
        let data = try JSONEncoder().encode(parent)
        let decoded = try JSONDecoder().decode(Parent.self, from: data)
        
        XCTAssertEqual(parent.id, decoded.id)
        XCTAssertEqual(parent.name, decoded.name)
        XCTAssertEqual(parent.isVerified, decoded.isVerified)
    }
    
    func testChildCodable() throws {
        let child = Child(id: "c1", parentId: "1", name: "Jane", age: 5, hobbies: ["Reading"])
        let data = try JSONEncoder().encode(child)
        let decoded = try JSONDecoder().decode(Child.self, from: data)
        
        XCTAssertEqual(child.id, decoded.id)
        XCTAssertEqual(child.name, decoded.name)
        XCTAssertEqual(child.hobbies, decoded.hobbies)
    }
    
    func testEventCodable() throws {
        let event = Event(id: "e1", title: "Park Meetup", description: "Fun in the sun", locationName: "Central Park", latitude: 40.7128, longitude: -74.0060, dateTime: Date(), organizerId: "1")
        let data = try JSONEncoder().encode(event)
        let decoded = try JSONDecoder().decode(Event.self, from: data)
        
        XCTAssertEqual(event.id, decoded.id)
        XCTAssertEqual(event.title, decoded.title)
        XCTAssertEqual(event.locationName, decoded.locationName)
    }
    
    func testChatMessageCodable() throws {
        let message = ChatMessage(id: "m1", senderId: "1", content: "Hello", type: .text)
        let data = try JSONEncoder().encode(message)
        let decoded = try JSONDecoder().decode(ChatMessage.self, from: data)
        
        XCTAssertEqual(message.id, decoded.id)
        XCTAssertEqual(message.content, decoded.content)
        XCTAssertEqual(message.type, decoded.type)
    }
    
    func testChatSessionCodable() throws {
        let session = ChatSession(id: "s1", participantIds: ["1", "2"], lastMessage: "Hello")
        let data = try JSONEncoder().encode(session)
        let decoded = try JSONDecoder().decode(ChatSession.self, from: data)
        
        XCTAssertEqual(session.id, decoded.id)
        XCTAssertEqual(session.participantIds, decoded.participantIds)
        XCTAssertEqual(session.lastMessage, decoded.lastMessage)
    }
    
    func testMatchCodable() throws {
        let match = Match(id: "match1", userIds: ["1", "2"])
        let data = try JSONEncoder().encode(match)
        let decoded = try JSONDecoder().decode(Match.self, from: data)
        
        XCTAssertEqual(match.id, decoded.id)
        XCTAssertEqual(match.userIds, decoded.userIds)
    }
}
