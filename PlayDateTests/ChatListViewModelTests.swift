import XCTest
@testable import PlayDate

@MainActor
class ChatListViewModelTests: XCTestCase {
    
    var viewModel: ChatListViewModel!
    var mockService: MockChatService!
    let testUserId = "user123"
    
    override func setUp() {
        super.setUp()
        mockService = MockChatService()
        viewModel = ChatListViewModel(chatService: mockService, userId: testUserId)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchSessionsSuccess() async {
        let sessions = [ChatSession(id: "s1", participantIds: [testUserId, "other"])]
        mockService.mockedSessions = sessions
        
        await viewModel.fetchSessions()
        
        XCTAssertEqual(viewModel.sessions.count, 1)
        XCTAssertEqual(viewModel.sessions.first?.id, "s1")
    }
    
    func testDeleteSessionSuccess() async {
        viewModel.sessions = [ChatSession(id: "s1", participantIds: [testUserId, "other"])]
        
        await viewModel.deleteSession(sessionId: "s1")
        
        XCTAssertTrue(viewModel.sessions.isEmpty)
        XCTAssertEqual(mockService.deletedSessionId, "s1")
    }
}
