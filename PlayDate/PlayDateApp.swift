import SwiftUI
import FirebaseCore

@main
struct PlayDateApp: App {
    init() {
        if !AppEnvironment.isPreview && FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    @State private var session = AuthSession()

    var body: some Scene {
        WindowGroup {
            AppRoot()
                .environment(session)
                .task {
                    if !AppEnvironment.isPreview {
                        await session.bootstrap()
                        await MockSeeder.seedIfNeeded()
                        if let userId = session.currentUser?.id {
                            await MockSeeder.seedUserDataIfNeeded(userId: userId)
                        }
                    }
                }
        }
    }
}

struct AppRoot: View {
    @Environment(AuthSession.self) private var session

    var body: some View {
        @Bindable var session = session

        Group {
            if session.isAuthenticated {
                RootTabView()
                    .sheet(isPresented: $session.needsOnboarding) {
                        OnboardingView()
                    }
            } else {
                LoginView()
            }
        }
    }
}

#Preview("Logged out") {
    AppRoot().environment(AuthSession())
}

#Preview("Logged in") {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    s.ownChildren = Parent.mockOwnChildren
    return AppRoot().environment(s)
}
