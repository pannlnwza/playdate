import SwiftUI

struct ChatListView: View {
    @State private var sessions: [ChatSession] = ChatSession.mockSessions

    private var recentMatches: [ChatSession] {
        Array(sessions.prefix(4))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            newMatchesSection
                            chatListSection
                        }
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            Text("Messages")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textMain)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var newMatchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("NEW MATCHES")
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .tracking(1)
                .foregroundStyle(Theme.textMuted)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recentMatches) { match in
                        NavigationLink {
                            ChatDetailView(session: match)
                        } label: {
                            NewMatchAvatar(conversation: match)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
            }
        }
    }

    private var chatListSection: some View {
        LazyVStack(spacing: 2) {
            ForEach(sessions) { session in
                NavigationLink {
                    ChatDetailView(session: session)
                } label: {
                    ConversationRow(conversation: session)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
    }
}

#Preview {
    ChatListView()
        .environment(AuthSession())
}
