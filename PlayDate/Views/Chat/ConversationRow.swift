import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation
    @Environment(AuthSession.self) private var auth

    private var currentUserId: String { auth.currentUser?.id ?? "" }
    private var displayName: String { conversation.otherName(currentUserId: currentUserId) ?? "" }
    private var displayImageUrl: String? { conversation.otherImageUrl(currentUserId: currentUserId) }

    var body: some View {
        HStack(spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
                    .lineLimit(1)

                Text(subtitleText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(subtitleColor)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 6) {
                if let timestamp = conversation.lastMessageTime {
                    Text(formatTime(timestamp))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textMuted)
                }

                if conversation.unreadCount > 0 {
                    Text("\(conversation.unreadCount)")
                        .font(.system(size: 11, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(minWidth: 22, minHeight: 22)
                        .background(Color(red: 239/255, green: 68/255, blue: 68/255), in: Circle())
                } else {
                    Color.clear.frame(width: 22, height: 22)
                }
            }
        }
        .padding(14)
        .contentShape(RoundedRectangle(cornerRadius: 20))
    }

    private var subtitleText: String {
        if let last = conversation.lastMessage, !last.isEmpty { return last }
        if let context = conversation.childContext, !context.isEmpty { return context }
        return ""
    }

    private var subtitleColor: Color {
        if conversation.lastMessage?.isEmpty == false { return Theme.textLight }
        return Theme.primary
    }

    private var avatar: some View {
        ZStack {
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
        .frame(width: 56, height: 56)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
            if conversation.isOnline {
                Circle()
                    .fill(Color(red: 34/255, green: 197/255, blue: 94/255))
                    .frame(width: 14, height: 14)
                    .overlay { Circle().strokeBorder(Theme.bg, lineWidth: 3) }
                    .offset(x: 2, y: 2)
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

    private func formatTime(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 { return "now" }
        if minutes < 60 { return "\(minutes)m ago" }
        if hours < 24 { return "\(hours)h ago" }
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days) days" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    return VStack(spacing: 2) {
        ConversationRow(conversation: ChatSession.mockSessions[0])
        ConversationRow(conversation: ChatSession.mockSessions[2])
        ConversationRow(conversation: ChatSession.mockSessions[3])
    }
    .padding()
    .background(Theme.bg)
    .environment(s)
}
