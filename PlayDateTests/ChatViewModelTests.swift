import XCTest
@testable import PlayDate

@MainActor
class ChatViewModelTests: XCTestCase {
    
    var viewModel: ChatViewModel!
    var mockService: MockChatService!
    let testUserId = "user123"
    let testSession = ChatSession(id: "s1", participantIds: ["user123", "other"])
    
    override func setUp() {
        super.setUp()
        mockService = MockChatService()
        viewModel = ChatViewModel(session: testSession, chatService: mockService, userId: testUserId)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchMessagesSuccess() async {
        let messages = [ChatMessage(id: "m1", senderId: "other", content: "Hi", type: .text)]
        mockService.mockedMessages = messages
        
        await viewModel.fetchMessages()
        
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.content, "Hi")
    }
    
    func testSendTextSuccess() async {
        await viewModel.sendText("Hello")
        
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.content, "Hello")
        XCTAssertEqual(mockService.sentMessage?.content, "Hello")
    }
    
    func testSendStickerSuccess() async {
        await viewModel.sendSticker(url: "sticker_url")
        
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.type, .sticker)
        XCTAssertEqual(mockService.sentMessage?.content, "sticker_url")
    }
    
    func testSendVoiceNoteSuccess() async {
        await viewModel.sendVoiceNote(url: "voice_url")
        
        XCTAssertEqual(viewModel.messages.count, 1)
        XCTAssertEqual(viewModel.messages.first?.type, .voiceNote)
        XCTAssertEqual(mockService.sentMessage?.content, "voice_url")
    }
}
