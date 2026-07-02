import Testing
import Foundation
@testable import HouseScore

@MainActor
final class FakeListingStore: ListingStore {
    var stored: [HouseListing] = []
    private(set) var addedPhotoData: [[Data]] = []
    private(set) var updateCalls = 0
    private(set) var deleted: [HouseListing] = []

    func fetchAll() -> [HouseListing] {
        stored.sorted { $0.visitedAt > $1.visitedAt }
    }

    func add(_ listing: HouseListing, photoData: [Data]) {
        stored.append(listing)
        addedPhotoData.append(photoData)
    }

    func update(_ listing: HouseListing, photosToAdd: [Data], photosToRemove: [ListingPhoto]) {
        updateCalls += 1
    }

    func delete(_ listing: HouseListing) {
        stored.removeAll { $0 === listing }
        deleted.append(listing)
    }
}

@MainActor
struct ListingsViewModelTests {
    @Test func initFetchesSortedListings() {
        let store = FakeListingStore()
        let older = HouseListing(address: "Older", visitedAt: Date(timeIntervalSince1970: 100))
        let newer = HouseListing(address: "Newer", visitedAt: Date(timeIntervalSince1970: 200))
        store.stored = [older, newer]

        let vm = ListingsViewModel(store: store)

        #expect(vm.listings.map(\.address) == ["Newer", "Older"])
    }

    @Test func addBuildsListingDelegatesAndRefreshes() {
        let store = FakeListingStore()
        let vm = ListingsViewModel(store: store)

        vm.add(
            address: "New",
            price: 100,
            rating: 4,
            notes: "",
            visitedAt: .now,
            propertyType: .house,
            contactPhone: nil,
            listingURL: nil,
            photoData: [Data([1])]
        )

        #expect(store.stored.count == 1)
        #expect(store.stored.first?.address == "New")
        #expect(store.stored.first?.propertyType == .house)
        #expect(store.addedPhotoData == [[Data([1])]])
        #expect(vm.listings.count == 1)
    }

    @Test func updateAssignsFieldsAndDelegates() {
        let store = FakeListingStore()
        let listing = HouseListing(address: "Old", price: 1, rating: 1)
        store.stored = [listing]
        let vm = ListingsViewModel(store: store)

        vm.update(
            listing,
            address: "New",
            price: 250,
            rating: 5,
            notes: "notes",
            visitedAt: .now,
            propertyType: .flat,
            contactPhone: "555",
            listingURL: "example.com",
            photosToAdd: [],
            photosToRemove: []
        )

        #expect(listing.address == "New")
        #expect(listing.price == 250)
        #expect(listing.rating == 5)
        #expect(listing.contactPhone == "555")
        #expect(store.updateCalls == 1)
    }

    @Test func deleteRemovesAndRefreshes() {
        let store = FakeListingStore()
        let a = HouseListing(address: "A", visitedAt: Date(timeIntervalSince1970: 200))
        let b = HouseListing(address: "B", visitedAt: Date(timeIntervalSince1970: 100))
        store.stored = [a, b]
        let vm = ListingsViewModel(store: store)

        vm.delete(a)

        #expect(store.deleted.contains { $0 === a })
        #expect(vm.listings.map(\.address) == ["B"])
    }

    @Test func deleteAtIndexRemovesSelectedRow() {
        let store = FakeListingStore()
        let a = HouseListing(address: "A", visitedAt: Date(timeIntervalSince1970: 300))
        let b = HouseListing(address: "B", visitedAt: Date(timeIntervalSince1970: 200))
        let c = HouseListing(address: "C", visitedAt: Date(timeIntervalSince1970: 100))
        store.stored = [a, b, c]
        let vm = ListingsViewModel(store: store)

        vm.delete(at: IndexSet(integer: 1))

        #expect(vm.listings.map(\.address) == ["A", "C"])
    }
}
