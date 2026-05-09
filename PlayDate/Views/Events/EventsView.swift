import SwiftUI

struct EventsView: View {
    @State private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            searchBar
                            categoryScroll

                            if let featured = viewModel.featuredEvent {
                                sectionTitle("Featured")
                                FeaturedEventCard(event: featured)
                                    .padding(.horizontal, 20)
                            }

                            sectionTitle("Upcoming")

                            if viewModel.upcomingEvents.isEmpty {
                                ContentUnavailableView(
                                    "No matching events",
                                    systemImage: "magnifyingglass",
                                    description: Text("Try a different category or search term.")
                                )
                                .padding(.top, 40)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.upcomingEvents) { event in
                                        EventCard(
                                            event: event,
                                            isJoined: viewModel.isJoined(event),
                                            onJoin: { viewModel.toggleJoin(event) }
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            Text("Events")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(Theme.textMain)
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textMuted)

            TextField("Search events near you...", text: $viewModel.searchText)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textMain)
                .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .background(Theme.cardBg, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        .padding(.horizontal, 20)
    }

    private var categoryScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryPill(label: "All", isActive: viewModel.selectedCategory == nil) {
                    withAnimation(.snappy) { viewModel.selectedCategory = nil }
                }

                ForEach(EventCategory.allCases) { category in
                    CategoryPill(
                        label: category.rawValue,
                        isActive: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.snappy) { viewModel.selectedCategory = category }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 20, weight: .heavy, design: .rounded))
            .foregroundStyle(Theme.textMain)
            .padding(.horizontal, 20)
    }
}

private struct CategoryPill: View {
    let label: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 13, weight: .heavy, design: .rounded))
                .foregroundStyle(isActive ? .white : Theme.textLight)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background {
                    if isActive {
                        Capsule().fill(Theme.brandGradient)
                    } else {
                        Capsule().fill(Theme.cardBg)
                    }
                }
                .shadow(
                    color: isActive ? Theme.primary.opacity(0.3) : .black.opacity(0.04),
                    radius: isActive ? 12 : 6,
                    y: 2
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EventsView()
}
