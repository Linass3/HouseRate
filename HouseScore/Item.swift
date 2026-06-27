//
//  HouseListing.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import Foundation
import SwiftData

@Model
final class HouseListing {
    var address: String
    var price: Double?
    var rating: Int
    var notes: String
    var visitedAt: Date

    init(
        address: String,
        price: Double? = nil,
        rating: Int = 3,
        notes: String = "",
        visitedAt: Date = .now
    ) {
        self.address = address
        self.price = price
        self.rating = rating
        self.notes = notes
        self.visitedAt = visitedAt
    }
}
