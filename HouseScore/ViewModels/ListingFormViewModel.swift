import Foundation
import Observation
import SwiftUI
import PhotosUI

enum ListingFormType: Hashable {
    case add(PropertyType)
    case edit(HouseListing)
}

@Observable
final class ListingFormViewModel {
    let type: ListingFormType

    var address: String
    var priceText: String
    var rating: Int
    var notes: String
    var visitedAt: Date
    var propertyType: PropertyType
    var contactPhone: String
    var listingURL: String

    var selectedPhotoItems: [PhotosPickerItem] = []
    private(set) var newPhotoData: [Data] = []
    private(set) var photosToRemove: [ListingPhoto] = []

    private let listingsViewModel: ListingsViewModel

    init(type: ListingFormType, listingsViewModel: ListingsViewModel) {
        self.type = type
        self.listingsViewModel = listingsViewModel
        switch type {
        case .add(let preselectedType):
            address = ""
            priceText = ""
            rating = 5
            notes = ""
            visitedAt = .now
            propertyType = preselectedType
            contactPhone = ""
            listingURL = ""
        case .edit(let listing):
            address = listing.address
            priceText = listing.price.map { String($0) } ?? ""
            rating = listing.rating
            notes = listing.notes
            visitedAt = listing.visitedAt
            propertyType = listing.propertyType
            contactPhone = listing.contactPhone ?? ""
            listingURL = listing.listingURL ?? ""
        }
    }

    var title: String {
        switch type {
        case .add(let propertyType): "New \(propertyType.displayName)"
        case .edit: "Edit Listing"
        }
    }

    var isEditing: Bool {
        if case .edit = type { return true }
        return false
    }

    var canSave: Bool {
        !address.trimmingCharacters(in: .whitespaces).isEmpty && !priceText.isEmpty
    }

    var existingPhotos: [ListingPhoto] {
        guard case .edit(let listing) = type else { return [] }
        return listing.photos
            .filter { !photosToRemove.contains($0) }
            .sorted { $0.createdAt < $1.createdAt }
    }

    func loadSelectedPhotos() async {
        let items = selectedPhotoItems
        guard !items.isEmpty else { return }
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self) {
                newPhotoData.append(data)
            }
        }
        selectedPhotoItems = []
    }

    func removeNewPhoto(at index: Int) {
        guard newPhotoData.indices.contains(index) else { return }
        newPhotoData.remove(at: index)
    }

    func removeExistingPhoto(_ photo: ListingPhoto) {
        photosToRemove.append(photo)
    }

    func save() {
        let price = Double(priceText)
        let trimmedAddress = address.trimmingCharacters(in: .whitespaces)
        let phone = contactPhone.trimmingCharacters(in: .whitespaces)
        let url = listingURL.trimmingCharacters(in: .whitespaces)

        switch type {
        case .add:
            listingsViewModel.add(
                address: trimmedAddress,
                price: price,
                rating: rating,
                notes: notes,
                visitedAt: visitedAt,
                propertyType: propertyType,
                contactPhone: phone.isEmpty ? nil : phone,
                listingURL: url.isEmpty ? nil : url,
                photoData: newPhotoData
            )
        case .edit(let listing):
            listingsViewModel.update(
                listing,
                address: trimmedAddress,
                price: price,
                rating: rating,
                notes: notes,
                visitedAt: visitedAt,
                propertyType: propertyType,
                contactPhone: phone.isEmpty ? nil : phone,
                listingURL: url.isEmpty ? nil : url,
                photosToAdd: newPhotoData,
                photosToRemove: photosToRemove
            )
        }
    }
}
