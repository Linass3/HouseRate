import Foundation
import SwiftData

@Model
final class ListingPhoto {

    @Attribute(.externalStorage)
    var imageData: Data
    var createdAt: Date

    init(imageData: Data) {
        self.imageData = imageData
        self.createdAt = .now
    }
}
