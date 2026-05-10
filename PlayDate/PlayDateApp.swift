import SwiftUI
import FirebaseCore

@main
struct PlayDateApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    @State private var session = AuthSession()

    var body: some Scene {
        WindowGroup {
            AppRoot()
                .environment(session)
        }
    }
}

private struct AppRoot: View {
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
