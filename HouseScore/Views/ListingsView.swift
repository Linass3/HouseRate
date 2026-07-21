import SwiftUI
import SwiftData

enum ListingsRoute: Hashable {
    case detail(HouseListing)
    case form(ListingFormType)
}

struct ListingsView: View {

    @State
    private var viewModel: ListingsViewModel

    init(viewModel: ListingsViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }

    init(modelContext: ModelContext) {
        self.init(viewModel: ListingsViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.listings) { listing in
                    NavigationLink(value: ListingsRoute.detail(listing)) {
                        ListingRowView(listing: listing)
                    }
                }
                .onDelete { index in
                    viewModel.delete(at: index)
                }
            }
            .overlay {
                if viewModel.listings.isEmpty {
                    ContentUnavailableView(
                        "No Listings",
                        systemImage: "house",
                        description: Text("Tap + to add a reviewed house")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(PropertyType.allCases) { type in
                            NavigationLink(value: ListingsRoute.form(.add(type))) {
                                Text(type.displayName)
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationDestination(for: ListingsRoute.self) { route in
                switch route {
                case .detail(let listing):
                    ListingDetailView(listing: listing, viewModel: viewModel)
                case .form(let type):
                    ListingFormView(type: type, viewModel: viewModel)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    ListingsView(modelContext: container.mainContext)
}
