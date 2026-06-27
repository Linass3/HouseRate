//
//  HouseListing.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import Foundation
import SwiftData

enum PropertyType: String, Codable, CaseIterable, Identifiable {
    case flat, cottage, house

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flat:    "Flat"
        case .cottage: "Cottage"
        case .house:   "House"
        }
    }
}

@Model
final class HouseListing {
    var address: String
    var price: Double?
    var rating: Int
    var notes: String
    var visitedAt: Date
    var propertyType: PropertyType = PropertyType.flat

    init(
        address: String,
        price: Double? = nil,
        rating: Int = 3,
        notes: String = "",
        visitedAt: Date = .now,
        propertyType: PropertyType = .flat
    ) {
        self.address = address
        self.price = price
        self.rating = rating
        self.notes = notes
        self.visitedAt = visitedAt
        self.propertyType = propertyType
    }
}
