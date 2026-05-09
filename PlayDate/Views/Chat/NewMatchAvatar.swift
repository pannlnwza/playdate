import SwiftUI

struct NewMatchAvatar: View {
    let conversation: Conversation

    var body: some View {
        VStack(spacing: 6) {
            avatar
            Text(conversation.parentName ?? "")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)
                .lineLimit(1)
                .frame(maxWidth: 68)
        }
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
            .frame(width: 60, height: 60)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .overlay {
                Circle().strokeBorder(Theme.bg, lineWidth: 3)
            }
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
}

#Preview {
    HStack(spacing: 16) {
        NewMatchAvatar(conversation: ChatSession.mockSessions[0])
        NewMatchAvatar(conversation: ChatSession.mockSessions[2])
    }
    .padding()
    .background(Theme.bg)
}
