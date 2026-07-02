import Foundation
import Observation
import SwiftData

@Observable
final class ListingsViewModel {
    private(set) var listings: [HouseListing] = []
    private let store: ListingStore

    init(store: ListingStore) {
        self.store = store
        fetch()
    }

    convenience init(modelContext: ModelContext) {
        self.init(store: SwiftDataListingStore(context: modelContext))
    }

    func fetch() {
        listings = store.fetchAll()
    }

    func add(
        address: String,
        price: Double?,
        rating: Int,
        notes: String,
        visitedAt: Date,
        propertyType: PropertyType,
        contactPhone: String?,
        listingURL: String?,
        photoData: [Data]
    ) {
        let listing = HouseListing(
            address: address,
            price: price,
            rating: rating,
            notes: notes,
            visitedAt: visitedAt,
            propertyType: propertyType,
            contactPhone: contactPhone,
            listingURL: listingURL
        )
        store.add(listing, photoData: photoData)
        fetch()
    }

    func update(
        _ listing: HouseListing,
        address: String,
        price: Double?,
        rating: Int,
        notes: String,
        visitedAt: Date,
        propertyType: PropertyType,
        contactPhone: String?,
        listingURL: String?,
        photosToAdd: [Data],
        photosToRemove: [ListingPhoto]
    ) {
        listing.address = address
        listing.price = price
        listing.rating = rating
        listing.notes = notes
        listing.visitedAt = visitedAt
        listing.propertyType = propertyType
        listing.contactPhone = contactPhone
        listing.listingURL = listingURL
        store.update(listing, photosToAdd: photosToAdd, photosToRemove: photosToRemove)
        fetch()
    }

    func delete(_ listing: HouseListing) {
        store.delete(listing)
        fetch()
    }

    func delete(at indexSet: IndexSet) {
        for index in indexSet {
            store.delete(listings[index])
        }
        fetch()
    }
}
