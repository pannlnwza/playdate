import Foundation

class MockAuthService: AuthServiceProtocol {
    var currentUser: Parent?
    var shouldReturnError = false
    
    func signIn() async throws -> Parent {
        if shouldReturnError {
            throw NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Sign in failed"])
        }
        let user = Parent(name: "Test Parent", email: "test@example.com")
        currentUser = user
        return user
    }
    
    func signOut() throws {
        currentUser = nil
    }
    
    func updateProfile(_ parent: Parent) async throws {
        if shouldReturnError {
            throw NSError(domain: "Auth", code: 400, userInfo: [NSLocalizedDescriptionKey: "Update failed"])
        }
        currentUser = parent
    }
}

class MockDataService: DataServiceProtocol {
    var shouldReturnError = false
    var mockedChildren: [Child] = []
    var mockedEvents: [Event] = []
    var swipedChildId: String?
    var swipedDirection: SwipeDirection?
    var joinedEventId: String?
    var createdEvent: Event?
    
    func fetchPotentialMatches() async throws -> [Child] {
        if shouldReturnError {
            throw NSError(domain: "Data", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fetch matches failed"])
        }
        return mockedChildren
    }
    
    func swipe(childId: String, direction: SwipeDirection) async throws {
        if shouldReturnError {
            throw NSError(domain: "Data", code: 500, userInfo: [NSLocalizedDescriptionKey: "Swipe failed"])
        }
        swipedChildId = childId
        swipedDirection = direction
    }
    
    func fetchEvents() async throws -> [Event] {
        if shouldReturnError {
            throw NSError(domain: "Data", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fetch events failed"])
        }
        return mockedEvents
    }
    
    func joinEvent(eventId: String, userId: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "Data", code: 500, userInfo: [NSLocalizedDescriptionKey: "Join failed"])
        }
        joinedEventId = eventId
    }
    
    func createEvent(_ event: Event) async throws {
        if shouldReturnError {
            throw NSError(domain: "Data", code: 500, userInfo: [NSLocalizedDescriptionKey: "Create failed"])
        }
        createdEvent = event
    }
}

class MockChatService: ChatServiceProtocol {
    var shouldReturnError = false
    var mockedSessions: [ChatSession] = []
    var mockedMessages: [ChatMessage] = []
    var sentMessage: ChatMessage?
    var deletedSessionId: String?
    
    func fetchSessions(for userId: String) async throws -> [ChatSession] {
        if shouldReturnError {
            throw NSError(domain: "Chat", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fetch sessions failed"])
        }
        return mockedSessions
    }
    
    func fetchMessages(for sessionId: String) async throws -> [ChatMessage] {
        if shouldReturnError {
            throw NSError(domain: "Chat", code: 500, userInfo: [NSLocalizedDescriptionKey: "Fetch messages failed"])
        }
        return mockedMessages
    }
    
    func sendMessage(_ message: ChatMessage, in sessionId: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "Chat", code: 500, userInfo: [NSLocalizedDescriptionKey: "Send failed"])
        }
        sentMessage = message
    }
    
    func deleteSession(_ sessionId: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "Chat", code: 500, userInfo: [NSLocalizedDescriptionKey: "Delete failed"])
        }
        deletedSessionId = sessionId
    }
}

class MockStorageService: StorageServiceProtocol {
    var shouldReturnError = false
    var uploadedData: Data?
    var uploadedPath: String?
    var deletedPath: String?
    var mockUrl = URL(string: "https://firebasestorage.googleapis.com/v0/b/mock/o/image.jpg")!
    
    func uploadImage(_ data: Data, path: String) async throws -> URL {
        if shouldReturnError {
            throw NSError(domain: "Storage", code: 500, userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
        }
        uploadedData = data
        uploadedPath = path
        return mockUrl
    }
    
    func deleteImage(path: String) async throws {
        if shouldReturnError {
            throw NSError(domain: "Storage", code: 500, userInfo: [NSLocalizedDescriptionKey: "Delete failed"])
        }
        deletedPath = path
    }
}
