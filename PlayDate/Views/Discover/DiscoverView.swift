import SwiftUI

struct DiscoverView: View {
    @State private var viewModel = DiscoverViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    cardStack
                    actionButtons
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $viewModel.showMatch) {
                if let child = viewModel.matchedChild {
                    MatchView(child: child)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("PlayDate")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.brandGradient)

            Spacer()

            Button {
                // notifications
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textMain)
                    .frame(width: 42, height: 42)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .overlay(alignment: .topTrailing) {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 10, height: 10)
                            .overlay { Circle().strokeBorder(Theme.cardBg, lineWidth: 2) }
                            .offset(x: -8, y: 8)
                    }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var cardStack: some View {
        ZStack {
            if viewModel.children.isEmpty {
                ContentUnavailableView(
                    "No more profiles",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("Check back later for new playmates.")
                )
            } else {
                ForEach(Array(viewModel.children.prefix(3).enumerated()).reversed(), id: \.element.id) { index, child in
                    ChildProfileCard(
                        child: child,
                        isTopCard: index == 0,
                        onSwipe: { direction in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                viewModel.swipe(direction)
                            }
                        }
                    )
                    .scaleEffect(1.0 - CGFloat(index) * 0.04)
                    .offset(y: CGFloat(index) * 8)
                    .zIndex(Double(viewModel.children.count - index))
                    .allowsHitTesting(index == 0)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .frame(maxHeight: .infinity)
    }

    private var actionButtons: some View {
        HStack(spacing: 20) {
            ActionButton(
                systemImage: "xmark",
                size: .large,
                foreground: Theme.primary,
                background: Theme.cardBg,
                shadowColor: Theme.primary.opacity(0.2)
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.swipe(.left)
                }
            }

            ActionButton(
                systemImage: "arrow.uturn.backward",
                size: .small,
                foreground: Theme.orange,
                background: Theme.cardBg,
                shadowColor: .black.opacity(0.1)
            ) {
                // rewind placeholder
            }

            ActionButton(
                systemImage: "heart.fill",
                size: .large,
                foreground: .white,
                gradient: Theme.likeGradient,
                shadowColor: Theme.secondary.opacity(0.4)
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.swipe(.right)
                }
            }
        }
        .padding(.vertical, 20)
    }
}

private struct ActionButton: View {
    enum Size { case small, large }

    let systemImage: String
    let size: Size
    let foreground: Color
    var background: Color = .white
    var gradient: LinearGradient? = nil
    let shadowColor: Color
    let action: () -> Void

    private var dimension: CGFloat { size == .small ? 48 : 64 }
    private var iconSize: CGFloat { size == .small ? 18 : 26 }

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: iconSize, weight: .bold))
                .foregroundStyle(foreground)
                .frame(width: dimension, height: dimension)
                .background {
                    if let gradient {
                        Circle().fill(gradient)
                    } else {
                        Circle().fill(background)
                    }
                }
                .shadow(color: shadowColor, radius: 12, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RootTabView()
}
