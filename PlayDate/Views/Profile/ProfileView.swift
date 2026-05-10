import SwiftUI

struct ProfileView: View {
    @Environment(AuthSession.self) private var session
    @State private var showEditProfile = false
    @State private var showAddChild = false
    @State private var editingChild: Child?
    @State private var eventsViewModel = EventsViewModel()

    private var parent: Parent? { session.currentUser }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(spacing: 20) {
                            profileHero
                            childrenSection
                            joinedEventsSection
                            settingsSection
                        }
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                let service: DataServiceProtocol = AppEnvironment.isPreview
                    ? MockDataService()
                    : FirestoreDataService(currentUserId: session.currentUser?.id)
                eventsViewModel.attach(service: service, userId: session.currentUser?.id)
                await eventsViewModel.load()
            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .sheet(isPresented: $showAddChild) {
            AddChildView()
        }
        .sheet(item: $editingChild) { child in
            AddChildView(editing: child)
                .environment(session)
        }
    }

    @ViewBuilder
    private var joinedEventsSection: some View {
        let joined = eventsViewModel.joinedUpcomingEvents
        if !joined.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Upcoming Events")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.textMain)
                    Spacer()
                }
                .padding(.horizontal, 20)

                LazyVStack(spacing: 12) {
                    ForEach(joined) { event in
                        NavigationLink {
                            EventDetailView(
                                event: event,
                                isJoined: true,
                                onToggleJoin: { eventsViewModel.toggleJoin(event) }
                            )
                        } label: {
                            EventCard(
                                event: event,
                                isJoined: true,
                                onJoin: { eventsViewModel.toggleJoin(event) }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Profile")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textMain)

            Spacer()

            Button {
                showEditProfile = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.textMain)
                    .frame(width: 42, height: 42)
                    .glassEffect(.regular.interactive(), in: Circle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var profileHero: some View {
        VStack(spacing: 0) {
            avatar
                .padding(.top, 8)

            Text(parent?.name ?? "")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.textMain)
                .padding(.top, 12)

            if let location = parent?.location, !location.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 11, weight: .bold))
                    Text(location)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(Theme.textLight)
                .padding(.top, 2)
            }

            if let bio = parent?.bio, !bio.isEmpty {
                Text(bio)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textLight)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.top, 6)
            }

            if parent?.isVerified == true {
                verifiedBadge
                    .padding(.top, 8)
            }
        }
    }

    private var avatar: some View {
        Group {
            if let image = session.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if let urlString = parent?.profileImageUrl, let url = URL(string: urlString) {
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
        .frame(width: 88, height: 88)
        .clipShape(Circle())
        .overlay { Circle().strokeBorder(Theme.bg, lineWidth: 4) }
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }

    private var avatarPlaceholder: some View {
        LinearGradient(
            colors: Theme.palette(for: parent?.id ?? "u"),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: "person.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.6))
        }
    }

    private var verifiedBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 12, weight: .bold))
            Text("Verified Parent")
                .font(.system(size: 12, weight: .heavy, design: .rounded))
        }
        .foregroundStyle(Color(red: 59/255, green: 130/255, blue: 246/255))
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(Color(red: 239/255, green: 246/255, blue: 1.0), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var childrenSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("My Children")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.textMain)

                Spacer()

                Button {
                    showAddChild = true
                } label: {
                    Text("+ Add Child")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundStyle(Theme.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            if session.ownChildren.isEmpty {
                emptyChildrenState
                    .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(session.ownChildren) { child in
                            Button {
                                editingChild = child
                            } label: {
                                ChildSummaryCard(child: child)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                }
            }
        }
    }

    private var emptyChildrenState: some View {
        Button {
            showAddChild = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "figure.child.circle")
                    .font(.system(size: 32))
                    .foregroundStyle(Theme.textMuted)
                Text("Add your first child to start matching")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.textLight)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
            .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    private var settingsSection: some View {
        VStack(spacing: 0) {
            Button {
                showEditProfile = true
            } label: {
                SettingsRow(
                    icon: "person.crop.circle.fill",
                    iconColor: Color(red: 139/255, green: 92/255, blue: 246/255),
                    iconBg: Color(red: 237/255, green: 233/255, blue: 254/255),
                    title: "Edit Profile",
                    subtitle: "Update your info and photos",
                    isLast: false
                )
            }
            .buttonStyle(.plain)

            Button {
                session.signOut()
            } label: {
                SettingsRow(
                    icon: "rectangle.portrait.and.arrow.right",
                    iconColor: Color(red: 245/255, green: 158/255, blue: 11/255),
                    iconBg: Color(red: 254/255, green: 243/255, blue: 199/255),
                    title: "Log Out",
                    subtitle: nil,
                    isLast: true
                )
            }
            .buttonStyle(.plain)
        }
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        .padding(.horizontal, 20)
    }
}

#Preview {
    let s = AuthSession()
    s.currentUser = .mockCurrentUser
    s.ownChildren = Parent.mockOwnChildren
    return ProfileView().environment(s)
}
