//
//  Item.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
