//
//  ListingsViewModel.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import Foundation
import Observation
import SwiftData

@Observable
final class ListingsViewModel {
    private(set) var listings: [HouseListing] = []
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetch()
    }

    func fetch() {
        let descriptor = FetchDescriptor<HouseListing>(
            sortBy: [SortDescriptor(\.visitedAt, order: .reverse)]
        )
        listings = (try? modelContext.fetch(descriptor)) ?? []
    }

    func add(
        address: String,
        price: Double?,
        rating: Int,
        notes: String,
        visitedAt: Date,
        propertyType: PropertyType
    ) {
        let listing = HouseListing(
            address: address,
            price: price,
            rating: rating,
            notes: notes,
            visitedAt: visitedAt,
            propertyType: propertyType
        )
        modelContext.insert(listing)
        fetch()
    }

    func update(
        _ listing: HouseListing,
        address: String,
        price: Double?,
        rating: Int,
        notes: String,
        visitedAt: Date,
        propertyType: PropertyType
    ) {
        listing.address = address
        listing.price = price
        listing.rating = rating
        listing.notes = notes
        listing.visitedAt = visitedAt
        listing.propertyType = propertyType
        fetch()
    }

    func delete(_ listing: HouseListing) {
        modelContext.delete(listing)
        fetch()
    }

    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            modelContext.delete(listings[index])
        }
        fetch()
    }
}
