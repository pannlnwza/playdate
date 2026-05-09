import SwiftUI

struct ConversationRow: View {
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 14) {
            avatar

            VStack(alignment: .leading, spacing: 2) {
                Text("\(conversation.parentName) \(conversation.childContext)")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
                    .lineLimit(1)

                Text(conversation.lastMessage)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textLight)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 6) {
                Text(formatTime(conversation.lastMessageTime))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)

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

    private var avatar: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: Theme.palette(for: conversation.id),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 56, height: 56)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.7))
            }
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
    VStack(spacing: 2) {
        ConversationRow(conversation: Conversation.mockConversations[0])
        ConversationRow(conversation: Conversation.mockConversations[2])
        ConversationRow(conversation: Conversation.mockConversations[3])
    }
    .padding()
    .background(Theme.bg)
}
