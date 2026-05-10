import SwiftUI

struct DiscoverView: View {
    @Environment(AuthSession.self) private var session
    @Environment(NotificationsViewModel.self) private var notifVM
    @State private var viewModel = DiscoverViewModel()
    @State private var showFilters = false
    @State private var showAddChild = false
    @State private var pendingChatSession: ChatSession?

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    if session.ownChildren.isEmpty {
                        addChildPrompt
                    } else {
                        cardStack
                        actionButtons
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $viewModel.showMatch) {
                if let child = viewModel.matchedChild {
                    MatchView(child: child, ownChild: session.ownChildren.first) {
                        openChat(with: child)
                    }
                }
            }
            .navigationDestination(item: $pendingChatSession) { chatSession in
                ChatDetailView(session: chatSession)
            }
            .sheet(isPresented: $showFilters) {
                DiscoverFiltersView(viewModel: viewModel)
                    .environment(session)
            }
            .sheet(isPresented: $showAddChild) {
                AddChildView()
                    .environment(session)
            }
            .task {
                let dataService: DataServiceProtocol = AppEnvironment.isPreview
                    ? MockDataService()
                    : FirestoreDataService(currentUserId: session.currentUser?.id)
                let chatService: ChatServiceProtocol = AppEnvironment.isPreview
                    ? MockChatService()
                    : FirestoreChatService()
                let notificationService: NotificationServiceProtocol = AppEnvironment.isPreview
                    ? MockNotificationService()
                    : FirestoreNotificationService()
                viewModel.attach(
                    dataService: dataService,
                    chatService: chatService,
                    notificationService: notificationService,
                    currentUserId: session.currentUser?.id,
                    currentUserName: session.currentUser?.name,
                    currentUserImageUrl: session.currentUser?.profileImageUrl,
                    ownChildIds: session.ownChildren.map(\.id)
                )
                await viewModel.load()
            }
        }
    }

    private var addChildPrompt: some View {
        VStack(spacing: 20) {
            Spacer()

            VStack(spacing: 8) {
                Text("Add a child to start matching")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)
                    .multilineTextAlignment(.center)

                Text("Other parents need to see who your kid is before you can find playmates.")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showAddChild = true
            } label: {
                Text("Add a Child")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Theme.primary, in: Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
    }

    private func openChat(with child: Child) {
        guard let userId = session.currentUser?.id else { return }
        let chatId = ChatId.make(userId, child.parentId)
        let chatSession = ChatSession(
            id: chatId,
            participantIds: [userId, child.parentId],
            parentName: child.parentName,
            childContext: "Just matched with \(child.name)",
            isNewMatch: true
        )
        viewModel.showMatch = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            pendingChatSession = chatSession
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text("PlayDate")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.brandGradient)

            Spacer()

            Button {
                showFilters = true
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textMain)
                    .frame(width: 42, height: 42)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .overlay(alignment: .topTrailing) {
                        if viewModel.hasActiveFilters {
                            Circle()
                                .fill(Theme.primary)
                                .frame(width: 10, height: 10)
                                .overlay { Circle().strokeBorder(Theme.cardBg, lineWidth: 2) }
                                .offset(x: -8, y: 8)
                        }
                    }
            }
            .buttonStyle(.plain)

            NavigationLink {
                NotificationsView()
            } label: {
                Image(systemName: "bell.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textMain)
                    .frame(width: 42, height: 42)
                    .glassEffect(.regular.interactive(), in: Circle())
                    .overlay(alignment: .topTrailing) {
                        if notifVM.unreadCount > 0 {
                            Text("\(notifVM.unreadCount)")
                                .font(.system(size: 10, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(minWidth: 16, minHeight: 16)
                                .padding(.horizontal, 3)
                                .background(Theme.primary, in: Capsule())
                                .overlay { Capsule().strokeBorder(Theme.bg, lineWidth: 2) }
                                .offset(x: -6, y: 6)
                        }
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private var cardStack: some View {
        let visibleChildren = viewModel.filteredChildren

        ZStack {
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.large)
            } else if visibleChildren.isEmpty {
                ContentUnavailableView(
                    viewModel.hasActiveFilters ? "No matches for these filters" : "No more profiles",
                    systemImage: viewModel.hasActiveFilters ? "line.3.horizontal.decrease.circle" : "person.crop.circle.badge.questionmark",
                    description: Text(viewModel.hasActiveFilters ? "Tap the filter icon to adjust." : "Check back later for new playmates.")
                )
            } else {
                ForEach(Array(visibleChildren.prefix(3).enumerated()).reversed(), id: \.element.id) { index, child in
                    ChildProfileCard(
                        child: child,
                        isTopCard: index == 0,
                        onSwipe: { direction in
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                viewModel.swipe(direction, child: child)
                            }
                        }
                    )
                    .scaleEffect(1.0 - CGFloat(index) * 0.04)
                    .offset(y: CGFloat(index) * 8)
                    .zIndex(Double(visibleChildren.count - index))
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
                shadowColor: Theme.primary.opacity(0.2),
                isEnabled: !viewModel.filteredChildren.isEmpty
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.swipeTop(.left)
                }
            }

            ActionButton(
                systemImage: "arrow.uturn.backward",
                size: .small,
                foreground: Theme.orange,
                background: Theme.cardBg,
                shadowColor: .black.opacity(0.1),
                isEnabled: viewModel.canRewind
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.rewind()
                }
            }

            ActionButton(
                systemImage: "hand.thumbsup.fill",
                size: .large,
                foreground: .white,
                gradient: Theme.likeGradient,
                shadowColor: Theme.secondary.opacity(0.4),
                isEnabled: !viewModel.filteredChildren.isEmpty
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    viewModel.swipeTop(.right)
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
    var isEnabled: Bool = true
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
                .opacity(isEnabled ? 1.0 : 0.4)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

#Preview {
    RootTabView()
        .environment(AuthSession())
}
