import XCTest
@testable import PlayDate

@MainActor
class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    var mockService: MockAuthService!
    
    override func setUp() {
        super.setUp()
        mockService = MockAuthService()
        viewModel = AuthViewModel(authService: mockService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testSignInSuccess() async {
        XCTAssertFalse(viewModel.isAuthenticated)
        
        await viewModel.signIn()
        
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.currentUser)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSignInFailure() async {
        mockService.shouldReturnError = true
        
        await viewModel.signIn()
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testSignOut() {
        // First sign in
        viewModel.isAuthenticated = true
        viewModel.currentUser = Parent(name: "Test", email: "test@example.com")
        
        viewModel.signOut()
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.currentUser)
    }
    
    func testUpdateProfileSuccess() async {
        // Set up initial user
        let initialUser = Parent(id: "1", name: "Initial", email: "test@test.com")
        viewModel.currentUser = initialUser
        mockService.currentUser = initialUser
        
        await viewModel.updateProfile(name: "Updated", bio: "New Bio")
        
        XCTAssertEqual(viewModel.currentUser?.name, "Updated")
        XCTAssertEqual(viewModel.currentUser?.bio, "New Bio")
        XCTAssertNil(viewModel.errorMessage)
    }
}
