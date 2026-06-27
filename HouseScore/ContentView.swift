//
//  ContentView.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel: ListingsViewModel
    @State private var propertyTypeToBeAdded: PropertyType?

    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: ListingsViewModel(modelContext: modelContext))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.listings) { listing in
                    NavigationLink {
                        ListingDetailView(listing: listing, viewModel: viewModel)
                    } label: {
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
                            Button(type.displayName) {
                                propertyTypeToBeAdded = type
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(item: $propertyTypeToBeAdded) { type in
                ListingFormView(type: .add(type), viewModel: viewModel)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    ContentView(modelContext: container.mainContext)
}
