//
//  ListingDetailView.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import SwiftUI
import SwiftData

struct ListingDetailView: View {
    let listing: HouseListing
    let viewModel: ListingsViewModel

    @State private var isEditing = false

    var body: some View {
        List {
            Section("Property") {
                LabeledContent("Type", value: listing.propertyType.displayName)
                LabeledContent("Address", value: listing.address)

                if let price = listing.price {
                    LabeledContent("Price") {
                        Text(price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                    }
                }

                LabeledContent("Visited") {
                    Text(listing.visitedAt, style: .date)
                }
            }

            if listing.contactPhone != nil || listing.listingURL != nil {
                Section("Contact") {
                    if let phone = listing.contactPhone {
                        Link(phone, destination: URL(string: "tel:\(phone.filter { !$0.isWhitespace })")!)
                    }
                    if let urlString = listing.listingURL {
                        let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)")!
                        Link(urlString, destination: url)
                    }
                }
            }

            Section("Your Review") {
                LabeledContent("Rating") {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= listing.rating ? "star.fill" : "star")
                                .foregroundStyle(.orange)
                        }
                    }
                }

                if !listing.notes.isEmpty {
                    Text(listing.notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(listing.address)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            ListingFormView(type: .edit(listing), viewModel: viewModel)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    let listing = HouseListing(address: "123 Main St", price: 450000, rating: 4, notes: "Nice garden, needs work on the roof.")
    let vm = ListingsViewModel(modelContext: container.mainContext)
    NavigationStack {
        ListingDetailView(listing: listing, viewModel: vm)
    }
}
