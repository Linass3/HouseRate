import Testing
import Foundation
import SwiftData
@testable import HouseScore

@MainActor
struct ListingFormViewModelTests {
    let container: ModelContainer

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: HouseListing.self, ListingPhoto.self, configurations: config)
    }

    private var context: ModelContext { container.mainContext }

    @Test func addModeStartsWithDefaults() {
        let vm = ListingFormViewModel(
            type: .add(.cottage),
            listingsViewModel: ListingsViewModel(modelContext: context)
        )
        #expect(vm.address.isEmpty)
        #expect(vm.priceText.isEmpty)
        #expect(vm.rating == 5)
        #expect(vm.propertyType == .cottage)
        #expect(vm.title == "New Cottage")
        #expect(vm.isEditing == false)
    }

    @Test func editModePopulatesFromListing() {
        let listing = HouseListing(
            address: "221B Baker Street",
            price: 500000,
            rating: 3,
            notes: "Great light",
            propertyType: .house,
            contactPhone: "555-1234",
            listingURL: "https://example.com"
        )
        let vm = ListingFormViewModel(
            type: .edit(listing),
            listingsViewModel: ListingsViewModel(modelContext: context)
        )
        #expect(vm.address == "221B Baker Street")
        #expect(vm.priceText == "500000.0")
        #expect(vm.rating == 3)
        #expect(vm.notes == "Great light")
        #expect(vm.propertyType == .house)
        #expect(vm.contactPhone == "555-1234")
        #expect(vm.listingURL == "https://example.com")
        #expect(vm.title == "Edit Listing")
        #expect(vm.isEditing == true)
    }

    @Test func canSaveRequiresNonBlankAddressAndPrice() {
        let vm = ListingFormViewModel(
            type: .add(.flat),
            listingsViewModel: ListingsViewModel(modelContext: context)
        )
        #expect(vm.canSave == false)

        vm.address = "123 Street"
        #expect(vm.canSave == false)

        vm.priceText = "300000"
        #expect(vm.canSave == true)

        vm.address = "   "
        #expect(vm.canSave == false)
    }

    @Test func saveInsertsTrimmedListingIntoStore() {
        let listingsVM = ListingsViewModel(modelContext: context)
        let vm = ListingFormViewModel(type: .add(.house), listingsViewModel: listingsVM)
        vm.address = "  221B Baker Street  "
        vm.priceText = "500000"
        vm.rating = 4
        vm.contactPhone = "   "
        vm.listingURL = "https://example.com"

        vm.save()

        #expect(listingsVM.listings.count == 1)
        let saved = try! #require(listingsVM.listings.first)
        #expect(saved.address == "221B Baker Street")
        #expect(saved.price == 500000)
        #expect(saved.rating == 4)
        #expect(saved.propertyType == .house)
        #expect(saved.contactPhone == nil)
        #expect(saved.listingURL == "https://example.com")
    }

    @Test func saveAppliesEditsToExistingListing() {
        let listing = HouseListing(address: "Old", price: 100, rating: 2, propertyType: .flat)
        context.insert(listing)
        let listingsVM = ListingsViewModel(modelContext: context)
        let vm = ListingFormViewModel(type: .edit(listing), listingsViewModel: listingsVM)

        vm.address = "New Address"
        vm.priceText = "250000"
        vm.rating = 5
        vm.save()

        #expect(listing.address == "New Address")
        #expect(listing.price == 250000)
        #expect(listing.rating == 5)
    }

    @Test func existingPhotosAreSortedByDateAndExcludeRemoved() {
        let listing = HouseListing(address: "A")
        let base = Date(timeIntervalSince1970: 1_000_000)
        let p1 = ListingPhoto(imageData: Data([1]))
        let p2 = ListingPhoto(imageData: Data([2]))
        let p3 = ListingPhoto(imageData: Data([3]))
        p1.createdAt = base
        p2.createdAt = base.addingTimeInterval(10)
        p3.createdAt = base.addingTimeInterval(20)
        listing.photos = [p3, p1, p2]
        context.insert(listing)

        let vm = ListingFormViewModel(
            type: .edit(listing),
            listingsViewModel: ListingsViewModel(modelContext: context)
        )
        #expect(vm.existingPhotos.map(\.imageData) == [Data([1]), Data([2]), Data([3])])

        vm.removeExistingPhoto(p2)
        #expect(vm.existingPhotos.map(\.imageData) == [Data([1]), Data([3])])
    }

    @Test func saveRemovesMarkedPhotosFromListing() {
        let listing = HouseListing(address: "A", price: 1)
        let p1 = ListingPhoto(imageData: Data([1]))
        let p2 = ListingPhoto(imageData: Data([2]))
        context.insert(listing)
        context.insert(p1)
        context.insert(p2)
        listing.photos = [p1, p2]

        let listingsVM = ListingsViewModel(modelContext: context)
        let vm = ListingFormViewModel(type: .edit(listing), listingsViewModel: listingsVM)
        vm.removeExistingPhoto(p1)
        vm.save()

        #expect(listing.photos.count == 1)
        #expect(listing.photos.first?.imageData == Data([2]))
    }

    @Test func removeNewPhotoIgnoresOutOfRangeIndex() {
        let vm = ListingFormViewModel(
            type: .add(.flat),
            listingsViewModel: ListingsViewModel(modelContext: context)
        )
        vm.removeNewPhoto(at: 5)
        #expect(vm.newPhotoData.isEmpty)
    }
}
