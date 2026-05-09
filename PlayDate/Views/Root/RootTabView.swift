import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "heart.fill") }

            EventsView()
                .tabItem { Label("Events", systemImage: "calendar") }

            ChatListView()
                .tabItem { Label("Chat", systemImage: "message.fill") }
                .badge(3)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
    }
}

#Preview {
    RootTabView()
}
