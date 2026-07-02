import Foundation
import SwiftData

@Model
final class HouseListing {
    var address: String
    var price: Double?
    var rating: Int
    var notes: String
    var visitedAt: Date
    var propertyType: PropertyType = PropertyType.flat
    var contactPhone: String?
    var listingURL: String?
    @Relationship(deleteRule: .cascade) var photos: [ListingPhoto] = []

    init(
        address: String,
        price: Double? = nil,
        rating: Int = 3,
        notes: String = "",
        visitedAt: Date = .now,
        propertyType: PropertyType = .flat,
        contactPhone: String? = nil,
        listingURL: String? = nil
    ) {
        self.address = address
        self.price = price
        self.rating = rating
        self.notes = notes
        self.visitedAt = visitedAt
        self.propertyType = propertyType
        self.contactPhone = contactPhone
        self.listingURL = listingURL
    }
}
