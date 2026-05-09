import SwiftUI

struct ChildProfileCard: View {
    let child: Child
    let isTopCard: Bool
    let onSwipe: (SwipeDirection) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var photoIndex: Int = 0

    private let photoCount = 3

    private var rotation: Double { Double(dragOffset.width / 20) }
    private var likeOpacity: Double { max(0, min(1, dragOffset.width / 100)) }
    private var nopeOpacity: Double { max(0, min(1, -dragOffset.width / 100)) }

    private var photoSeed: String { "\(child.id)-\(photoIndex)" }

    var body: some View {
        ZStack {
            background
            photoTapZones
            bottomGradient
            topRow
            swipeLabels
            cardContent
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, y: 10)
        .offset(dragOffset)
        .rotationEffect(.degrees(rotation), anchor: .bottom)
        .gesture(isTopCard ? dragGesture : nil)
    }

    private var background: some View {
        LinearGradient(
            colors: Theme.palette(for: photoSeed),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "figure.child.circle.fill")
                .font(.system(size: 120))
                .foregroundStyle(.white.opacity(0.35))
        }
        .animation(.easeInOut(duration: 0.25), value: photoIndex)
    }

    private var photoTapZones: some View {
        HStack(spacing: 0) {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { previousPhoto() }
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { nextPhoto() }
        }
        .frame(maxHeight: .infinity)
        .padding(.bottom, 200)
        .allowsHitTesting(isTopCard)
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.3), .black.opacity(0.7)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
        .mask {
            VStack(spacing: 0) {
                Color.clear
                LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                    .frame(height: 320)
            }
        }
        .allowsHitTesting(false)
    }

    private var topRow: some View {
        VStack {
            HStack(alignment: .top) {
                parentBadge
                Spacer()
                infoLink
            }
            Spacer()
        }
        .padding(16)
    }

    private var parentBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(LinearGradient(
                    colors: Theme.palette(for: child.parentName ?? child.parentId),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "person.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .overlay {
                    Circle().strokeBorder(.white.opacity(0.5), lineWidth: 2)
                }

            Text(child.parentName ?? "")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if child.parentVerified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.blue)
            }
        }
        .padding(.vertical, 4)
        .padding(.leading, 4)
        .padding(.trailing, 12)
        .background { Capsule().fill(.ultraThinMaterial) }
        .overlay { Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 1.5) }
        .allowsHitTesting(false)
    }

    private var infoLink: some View {
        NavigationLink {
            ChildDetailView(child: child)
        } label: {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(isTopCard)
    }

    private var swipeLabels: some View {
        HStack {
            Text("PLAY!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Theme.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.secondary, lineWidth: 4)
                }
                .rotationEffect(.degrees(-20))
                .opacity(likeOpacity)

            Spacer()

            Text("PASS")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(Theme.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.primary, lineWidth: 4)
                }
                .rotationEffect(.degrees(20))
                .opacity(nopeOpacity)
        }
        .padding(.horizontal, 24)
        .padding(.top, 80)
        .frame(maxHeight: .infinity, alignment: .top)
        .allowsHitTesting(false)
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            Spacer()

            photoDots

            Text("\(child.name), \(child.age)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

            Text(detailText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))

            FlowLayout(spacing: 6) {
                ForEach(child.interests, id: \.self) { interest in
                    Text(interest)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background { Capsule().fill(.ultraThinMaterial) }
                        .overlay { Capsule().strokeBorder(.white.opacity(0.3), lineWidth: 1) }
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .allowsHitTesting(false)
    }

    private var photoDots: some View {
        HStack(spacing: 4) {
            ForEach(0..<photoCount, id: \.self) { i in
                Capsule()
                    .fill(i == photoIndex ? Color.white : Color.white.opacity(0.4))
                    .frame(width: i == photoIndex ? 28 : 18, height: 4)
                    .animation(.easeInOut(duration: 0.2), value: photoIndex)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 4)
    }

    private var detailText: String {
        let bio = child.bio ?? ""
        guard let distance = child.distanceKm else { return bio }
        let distanceStr = String(format: "%.1f km", distance)
        return bio.isEmpty ? distanceStr : "\(bio) • \(distanceStr)"
    }

    private func previousPhoto() {
        guard photoIndex > 0 else { return }
        photoIndex -= 1
    }

    private func nextPhoto() {
        guard photoIndex < photoCount - 1 else { return }
        photoIndex += 1
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                if abs(value.translation.width) > 120 {
                    let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
                    let exitX: CGFloat = direction == .right ? 800 : -800
                    withAnimation(.easeOut(duration: 0.3)) {
                        dragOffset = CGSize(width: exitX, height: value.translation.height)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSwipe(direction)
                    }
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        dragOffset = .zero
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        ChildProfileCard(
            child: Child.mockChildren[0],
            isTopCard: true,
            onSwipe: { _ in }
        )
        .padding()
        .frame(maxHeight: 600)
        .background(Theme.bg)
    }
}
