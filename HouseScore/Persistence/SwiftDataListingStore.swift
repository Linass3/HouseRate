import Foundation
import SwiftData

struct SwiftDataListingStore: ListingStore {
    let context: ModelContext

    func fetchAll() -> [HouseListing] {
        let descriptor = FetchDescriptor<HouseListing>(
            sortBy: [SortDescriptor(\.visitedAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    func add(_ listing: HouseListing, photoData: [Data]) {
        context.insert(listing)
        for data in photoData {
            let photo = ListingPhoto(imageData: data)
            context.insert(photo)
            listing.photos.append(photo)
        }
    }

    func update(_ listing: HouseListing, photosToAdd: [Data], photosToRemove: [ListingPhoto]) {
        for data in photosToAdd {
            let photo = ListingPhoto(imageData: data)
            context.insert(photo)
            listing.photos.append(photo)
        }
        for photo in photosToRemove {
            listing.photos.removeAll { $0.id == photo.id }
            context.delete(photo)
        }
    }

    func delete(_ listing: HouseListing) {
        context.delete(listing)
    }
}
