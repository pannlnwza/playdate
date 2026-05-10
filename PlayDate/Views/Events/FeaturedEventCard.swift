import SwiftUI

struct FeaturedEventCard: View {
    let event: Event

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            background
            bottomGradient
            content
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 8)
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 102/255, green: 126/255, blue: 234/255),
                Color(red: 118/255, green: 75/255, blue: 162/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .trailing) {
            Image(systemName: categoryIcon)
                .font(.system(size: 90))
                .foregroundStyle(.white.opacity(0.18))
                .padding(.trailing, 30)
        }
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.2), .black.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(featuredLabel)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .tracking(1.5)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))

            Text(event.title)
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text("\(event.location) • Ages \(event.minAge)-\(event.maxAge) • \(event.startTime)")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            attendees
                .padding(.top, 4)
        }
        .padding(20)
    }

    private var attendees: some View {
        HStack(spacing: -8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(LinearGradient(
                        colors: Theme.cardPalettes[index % Theme.cardPalettes.count],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .overlay { Circle().strokeBorder(.white, lineWidth: 2) }
            }

            Text("+\(event.attendingFamilyCount) families going")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.leading, 12)
        }
    }

    private var featuredLabel: String {
        let calendar = Calendar.current
        let daysFromNow = calendar.dateComponents([.day], from: Date(), to: event.date).day ?? 0

        if daysFromNow <= 0 {
            return "TODAY"
        } else if daysFromNow == 1 {
            return "TOMORROW"
        } else if daysFromNow <= 7 {
            let weekday = event.date.formatted(.dateTime.weekday(.wide))
            return "THIS \(weekday.uppercased())"
        } else {
            return event.date.formatted(.dateTime.month(.abbreviated).day()).uppercased()
        }
    }

    private var categoryIcon: String {
        switch event.category {
        case .outdoors: return "leaf.fill"
        case .sports: return "soccerball"
        case .arts: return "paintpalette.fill"
        case .music: return "music.note"
        case .storytime: return "book.fill"
        }
    }
}

#Preview {
    FeaturedEventCard(event: Event.mockEvents[0])
        .padding()
        .background(Theme.bg)
}
