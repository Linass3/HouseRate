//
//  ListingFormView.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import SwiftUI
import SwiftData

enum ListingFormType {
    case add
    case edit(HouseListing)
}

struct ListingFormView: View {
    let type: ListingFormType
    let viewModel: ListingsViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var address: String
    @State private var priceText: String
    @State private var rating: Int
    @State private var notes: String
    @State private var visitedAt: Date

    init(type: ListingFormType, viewModel: ListingsViewModel) {
        self.type = type
        self.viewModel = viewModel
        if case .edit(let listing) = type {
            _address = State(initialValue: listing.address)
            _priceText = State(initialValue: listing.price.map { String($0) } ?? "")
            _rating = State(initialValue: listing.rating)
            _notes = State(initialValue: listing.notes)
            _visitedAt = State(initialValue: listing.visitedAt)
        } else {
            _address = State(initialValue: "")
            _priceText = State(initialValue: "")
            _rating = State(initialValue: 5)
            _notes = State(initialValue: "")
            _visitedAt = State(initialValue: .now)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Property") {
                    TextField("Address", text: $address)
                    TextField("Asking Price", text: $priceText)
                        .keyboardType(.numberPad)
                    DatePicker("Visit Date", selection: $visitedAt, displayedComponents: .date)
                }

                Section("Your Review") {
                    Stepper("Rating: \(rating) / 5", value: $rating, in: 1...5)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(4...)
                }
            }
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(requirementsNotMet)
                }
            }
        }
    }

    private var titleText: String {
        switch type {
        case .add: "New Listing"
        case .edit: "Edit Listing"
        }
    }

    private func save() {
        let price = Double(priceText)
        let trimmedAddress = address.trimmingCharacters(in: .whitespaces)
        switch type {
        case .add:
            viewModel.add(address: trimmedAddress, price: price, rating: rating, notes: notes, visitedAt: visitedAt)
        case .edit(let listing):
            viewModel.update(listing, address: trimmedAddress, price: price, rating: rating, notes: notes, visitedAt: visitedAt)
        }
        dismiss()
    }

    private var requirementsNotMet: Bool {
        address.trimmingCharacters(in: .whitespaces).isEmpty || priceText.isEmpty
    }
}

#Preview("Add") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    ListingFormView(type: .add, viewModel: ListingsViewModel(modelContext: container.mainContext))
}

#Preview("Edit") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    let listing = HouseListing(address: "123 Main St", price: 450000, rating: 4, notes: "Nice garden")
    ListingFormView(type: .edit(listing), viewModel: ListingsViewModel(modelContext: container.mainContext))
}
