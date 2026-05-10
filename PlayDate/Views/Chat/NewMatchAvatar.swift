import SwiftUI

struct NewMatchAvatar: View {
    let conversation: Conversation
    @Environment(AuthSession.self) private var auth

    private var currentUserId: String { auth.currentUser?.id ?? "" }
    private var displayName: String { conversation.otherName(currentUserId: currentUserId) ?? "" }
    private var displayImageUrl: String? { conversation.otherImageUrl(currentUserId: currentUserId) }

    var body: some View {
        VStack(spacing: 6) {
            avatar
            Text(displayName)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)
                .lineLimit(1)
                .frame(maxWidth: 68)
        }
    }

    private var avatar: some View {
        Group {
            if let urlString = displayImageUrl, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .overlay { Circle().strokeBorder(Theme.bg, lineWidth: 3) }
        .padding(3)
        .background {
            if conversation.isNewMatch {
                Circle().fill(
                    LinearGradient(
                        colors: [Theme.primary, Theme.purple, Theme.secondary],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            } else {
                Circle().fill(Color.gray.opacity(0.25))
            }
        }
    }

    private var avatarPlaceholder: some View {
        LinearGradient(
            colors: Theme.palette(for: conversation.id),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "person.fill")
                .font(.system(size: 24))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    return HStack(spacing: 16) {
        NewMatchAvatar(conversation: ChatSession.mockSessions[0])
        NewMatchAvatar(conversation: ChatSession.mockSessions[2])
    }
    .padding()
    .background(Theme.bg)
    .environment(s)
}
