import Foundation

protocol ListingStore {
    func fetchAll() -> [HouseListing]
    func add(_ listing: HouseListing, photoData: [Data])
    func update(_ listing: HouseListing, photosToAdd: [Data], photosToRemove: [ListingPhoto])
    func delete(_ listing: HouseListing)
}
