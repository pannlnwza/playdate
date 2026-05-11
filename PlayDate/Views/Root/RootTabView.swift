import SwiftUI

struct RootTabView: View {
    @Environment(AuthSession.self) private var session
    @State private var chatVM = ChatListViewModel()
    @State private var notifVM = NotificationsViewModel()

    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "figure.2.and.child.holdinghands") }

            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }

            ChatListView()
                .tabItem { Label("Chat", systemImage: "message.fill") }
                .badge(chatVM.unreadCount)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
        .environment(chatVM)
        .environment(notifVM)
        .task {
            guard let userId = session.currentUser?.id else { return }
            let chatService: ChatServiceProtocol = AppEnvironment.isPreview
                ? MockChatService()
                : FirestoreChatService()
            chatVM.attach(service: chatService, userId: userId)

            let notifService: NotificationServiceProtocol = AppEnvironment.isPreview
                ? MockNotificationService()
                : FirestoreNotificationService()
            notifVM.attach(service: notifService, userId: userId)
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    s.ownChildren = Parent.mockOwnChildren
    return RootTabView().environment(s)
}
