import SwiftUI

struct ChildDetailLoader: View {
    let childId: String
    let chatSession: ChatSession?

    @Environment(AuthSession.self) private var session
    @State private var child: Child?
    @State private var failed = false

    var body: some View {
        Group {
            if let child {
                ChildDetailView(child: child, chatSession: chatSession)
            } else if failed {
                ContentUnavailableView(
                    "Couldn't load profile",
                    systemImage: "exclamationmark.triangle",
                    description: Text("Try again later.")
                )
            } else {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.bg)
            }
        }
        .task {
            let service: DataServiceProtocol = AppEnvironment.isPreview
                ? MockDataService()
                : FirestoreDataService(currentUserId: session.currentUser?.id)
            do {
                guard var loaded = try await service.loadChild(id: childId) else {
                    failed = true
                    return
                }
                if let parent = try? await service.loadParent(id: loaded.parentId) {
                    loaded.parentName = parent.name
                    loaded.parentImageUrl = parent.profileImageUrl
                    loaded.parentVerified = parent.isVerified
                }
                child = loaded
            } catch {
                failed = true
            }
        }
    }
}
