import SwiftUI

struct NotificationsView: View {
    @Environment(AuthSession.self) private var session
    @Environment(NotificationsViewModel.self) private var viewModel

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Theme.bg)
            } else if viewModel.notifications.isEmpty {
                ContentUnavailableView(
                    "No notifications",
                    systemImage: "bell.slash",
                    description: Text("You're all caught up.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bg)
            } else {
                List {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .onTapGesture {
                                viewModel.markRead(notification)
                            }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Theme.bg)
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !viewModel.notifications.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Mark all read") { viewModel.markAllRead() }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
        }
        .toolbarBackground(Theme.bg, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.delete(viewModel.notifications[index])
        }
    }
}

private struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: notification.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(iconBackground, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
                    .lineLimit(1)

                Text(notification.body)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textLight)
                    .lineLimit(2)

                Text(formatTime(notification.timestamp))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textMuted)
                    .padding(.top, 2)
            }

            Spacer(minLength: 8)

            if !notification.isRead {
                Circle()
                    .fill(Theme.primary)
                    .frame(width: 9, height: 9)
                    .padding(.top, 18)
            }
        }
        .padding(14)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var iconBackground: Color {
        switch notification.kind {
        case .match: return Theme.primary
        case .message: return Theme.purple
        case .event, .eventReminder: return Theme.secondary
        }
    }

    private func formatTime(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)

        if minutes < 1 { return "Just now" }
        if minutes < 60 { return "\(minutes)m ago" }
        if hours < 24 { return "\(hours)h ago" }
        if days == 1 { return "Yesterday" }
        if days < 7 { return "\(days) days ago" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    let notifVM = NotificationsViewModel()
    return NavigationStack {
        NotificationsView().environment(s).environment(notifVM)
    }
}
