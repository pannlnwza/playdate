import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem { Label("Discover", systemImage: "heart.fill") }

            ComingSoonScreen(title: "Events")
                .tabItem { Label("Events", systemImage: "calendar") }

            ComingSoonScreen(title: "Messages")
                .tabItem { Label("Chat", systemImage: "message.fill") }
                .badge(3)

            ComingSoonScreen(title: "Profile")
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Theme.primary)
    }
}

private struct ComingSoonScreen: View {
    let title: String

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Text(title)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(Theme.textMain)

                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    ContentUnavailableView(
                        "Coming soon",
                        systemImage: "hammer.fill",
                        description: Text("This screen is under construction.")
                    )
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    RootTabView()
}
