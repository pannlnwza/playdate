import SwiftUI

struct ChildSummaryCard: View {
    let child: Child
    @Environment(AuthSession.self) private var session

    var body: some View {
        VStack(spacing: 10) {
            avatar

            Text(child.name)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Text("\(child.age) years old")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textLight)

            FlowLayout(spacing: 4) {
                ForEach(child.interests, id: \.self) { interest in
                    interestTag(interest)
                }
            }
            .padding(.top, 2)
        }
        .frame(width: 160)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var avatar: some View {
        Group {
            if let image = session.childImages[child.id] {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: Theme.palette(for: child.id),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
        }
        .frame(width: 64, height: 64)
        .clipShape(Circle())
    }

    private func interestTag(_ interest: String) -> some View {
        let palette = interestPalette(for: interest)
        return Text(interest)
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .foregroundStyle(palette.foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(palette.background, in: Capsule())
    }

    private func interestPalette(for interest: String) -> (background: Color, foreground: Color) {
        switch interest.lowercased() {
        case "soccer", "outdoors", "swimming":
            return (Color(red: 219/255, green: 234/255, blue: 254/255), Color(red: 59/255, green: 130/255, blue: 246/255))
        case "lego", "science", "reading":
            return (Color(red: 209/255, green: 250/255, blue: 229/255), Color(red: 16/255, green: 185/255, blue: 129/255))
        case "dance", "music":
            return (Color(red: 254/255, green: 243/255, blue: 199/255), Color(red: 245/255, green: 158/255, blue: 11/255))
        case "art", "crafts", "stories":
            return (Color(red: 252/255, green: 231/255, blue: 243/255), Color(red: 236/255, green: 72/255, blue: 153/255))
        default:
            return (Color(red: 237/255, green: 233/255, blue: 254/255), Color(red: 139/255, green: 92/255, blue: 246/255))
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ChildSummaryCard(child: Parent.mockOwnChildren[0])
        ChildSummaryCard(child: Parent.mockOwnChildren[1])
    }
    .padding()
    .background(Theme.bg)
    .environment(AuthSession())
}
