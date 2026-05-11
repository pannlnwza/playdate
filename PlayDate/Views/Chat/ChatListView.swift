import SwiftUI

struct ChatListView: View {
    @Environment(AuthSession.self) private var session
    @Environment(ChatListViewModel.self) private var viewModel

    private var recentMatches: [ChatSession] {
        Array(viewModel.sessions.prefix(4))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    if viewModel.isLoading {
                        ProgressView()
                            .controlSize(.large)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.sessions.isEmpty {
                        ContentUnavailableView(
                            "No conversations yet",
                            systemImage: "message",
                            description: Text("Swipe right on Discover to start a chat.")
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                if !recentMatches.isEmpty {
                                    newMatchesSection
                                }
                                chatListSection
                            }
                            .padding(.bottom, 24)
                        }
                        .scrollIndicators(.hidden)
                    }
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
                        if let childId = match.childIdForCurrentUser(session.currentUser?.id ?? "") {
                            NavigationLink {
                                ChildDetailLoader(childId: childId, chatSession: match)
                            } label: {
                                NewMatchAvatar(conversation: match)
                            }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink {
                                ChatDetailView(session: match)
                            } label: {
                                NewMatchAvatar(conversation: match)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 4)
            }
        }
    }

    private var chatListSection: some View {
        LazyVStack(spacing: 2) {
            ForEach(viewModel.sessions) { session in
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
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    let chatVM = ChatListViewModel()
    return ChatListView().environment(s).environment(chatVM)
}
