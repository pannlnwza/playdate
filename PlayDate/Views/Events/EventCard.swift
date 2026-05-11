import SwiftUI

struct EventCard: View {
    let event: Event
    let isJoined: Bool
    let onJoin: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
                    .lineLimit(1)

                Text("\(event.location) • Ages \(event.minAge)-\(event.maxAge)")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textLight)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10, weight: .bold))
                    Text("\(event.startTime) - \(event.endTime)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Theme.textMuted)
                .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            joinButton
        }
        .padding(16)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let urlString = event.imageUrl, let url = URL(string: urlString) {
            ZStack {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        dateBox
                    }
                }

                LinearGradient(
                    colors: [.black.opacity(0.45), .black.opacity(0.15)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(spacing: 2) {
                    Text(monthString)
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .opacity(0.85)
                    Text(dayString)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                }
                .foregroundStyle(.white)
            }
            .frame(width: 56, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            dateBox
        }
    }

    private var dateBox: some View {
        let palette = dateColors(for: event.category)
        return VStack(spacing: 2) {
            Text(monthString)
                .font(.system(size: 10, weight: .heavy, design: .rounded))
                .tracking(1)
                .opacity(0.85)
            Text(dayString)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(palette.foreground)
        .frame(width: 56, height: 60)
        .background(
            LinearGradient(
                colors: palette.background,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }

    private var joinButton: some View {
        Button(action: onJoin) {
            Text(isJoined ? "Going" : "Join")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(isJoined ? Theme.secondary : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isJoined ? Color(red: 240/255, green: 253/255, blue: 244/255) : Theme.primary,
                    in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }

    private var monthString: String {
        event.date.formatted(.dateTime.month(.abbreviated)).uppercased()
    }

    private var dayString: String {
        event.date.formatted(.dateTime.day())
    }

    private func dateColors(for category: EventCategory) -> (background: [Color], foreground: Color) {
        switch category {
        case .sports:
            return (
                [Color(red: 254/255, green: 226/255, blue: 226/255), Color(red: 254/255, green: 202/255, blue: 202/255)],
                Color(red: 239/255, green: 68/255, blue: 68/255)
            )
        case .storytime:
            return (
                [Color(red: 224/255, green: 231/255, blue: 1.0), Color(red: 199/255, green: 210/255, blue: 254/255)],
                Color(red: 99/255, green: 102/255, blue: 241/255)
            )
        case .arts:
            return (
                [Color(red: 209/255, green: 250/255, blue: 229/255), Color(red: 167/255, green: 243/255, blue: 208/255)],
                Color(red: 16/255, green: 185/255, blue: 129/255)
            )
        case .music:
            return (
                [Color(red: 254/255, green: 243/255, blue: 199/255), Color(red: 253/255, green: 230/255, blue: 138/255)],
                Color(red: 245/255, green: 158/255, blue: 11/255)
            )
        case .outdoors:
            return (
                [Color(red: 220/255, green: 252/255, blue: 231/255), Color(red: 187/255, green: 247/255, blue: 208/255)],
                Color(red: 34/255, green: 197/255, blue: 94/255)
            )
        case .educational:
            return (
                [Color(red: 219/255, green: 234/255, blue: 254/255), Color(red: 191/255, green: 219/255, blue: 254/255)],
                Color(red: 59/255, green: 130/255, blue: 246/255)
            )
        case .sensory:
            return (
                [Color(red: 252/255, green: 231/255, blue: 243/255), Color(red: 251/255, green: 207/255, blue: 232/255)],
                Color(red: 236/255, green: 72/255, blue: 153/255)
            )
        case .fitness:
            return (
                [Color(red: 207/255, green: 250/255, blue: 254/255), Color(red: 165/255, green: 243/255, blue: 252/255)],
                Color(red: 6/255, green: 182/255, blue: 212/255)
            )
        case .social:
            return (
                [Color(red: 255/255, green: 237/255, blue: 213/255), Color(red: 254/255, green: 215/255, blue: 170/255)],
                Color(red: 249/255, green: 115/255, blue: 22/255)
            )
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        EventCard(event: Event.mockEvents[1], isJoined: false, onJoin: {})
        EventCard(event: Event.mockEvents[2], isJoined: true, onJoin: {})
        EventCard(event: Event.mockEvents[3], isJoined: false, onJoin: {})
    }
    .padding()
    .background(Theme.bg)
}
