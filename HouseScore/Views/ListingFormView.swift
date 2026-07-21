import SwiftUI
import SwiftData
import PhotosUI

struct ListingFormView: View {

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var viewModel: ListingFormViewModel

    var onSave: () -> Void = {}

    init(
        type: ListingFormType,
        viewModel: ListingsViewModel,
        onSave: @escaping () -> Void = {}
    ) {
        self._viewModel = State(initialValue: ListingFormViewModel(type: type, listingsViewModel: viewModel))
        self.onSave = onSave
    }

    var body: some View {
        Form {
                Section("Property") {
                    if viewModel.isEditing {
                        Picker("Type", selection: $viewModel.propertyType) {
                            ForEach(PropertyType.allCases, id: \.self) { t in
                                Text(t.displayName).tag(t)
                            }
                        }
                    }
                    TextField("Address", text: $viewModel.address)
                    TextField("Asking Price", text: $viewModel.priceText)
                        .keyboardType(.numberPad)
                    DatePicker("Visit Date", selection: $viewModel.visitedAt, displayedComponents: .date)
                }

                Section("Photos") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.existingPhotos) { photo in
                                if let img = UIImage(data: photo.imageData) {
                                    photoThumbnail(Image(uiImage: img)) {
                                        viewModel.removeExistingPhoto(photo)
                                    }
                                }
                            }
                            ForEach(viewModel.newPhotoData.indices, id: \.self) { idx in
                                if let img = UIImage(data: viewModel.newPhotoData[idx]) {
                                    photoThumbnail(Image(uiImage: img)) {
                                        viewModel.removeNewPhoto(at: idx)
                                    }
                                }
                            }
                            PhotosPicker(selection: $viewModel.selectedPhotoItems, maxSelectionCount: 10, matching: .images) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .frame(width: 80, height: 80)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .onChange(of: viewModel.selectedPhotoItems) {
                    Task { await viewModel.loadSelectedPhotos() }
                }

                Section("Contact") {
                    TextField("Phone Number", text: $viewModel.contactPhone)
                        .keyboardType(.phonePad)
                    TextField("Listing URL", text: $viewModel.listingURL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }

                Section("Your Review") {
                    Stepper("Rating: \(viewModel.rating) / 5", value: $viewModel.rating, in: 1...5)
                    TextField("Notes", text: $viewModel.notes, axis: .vertical)
                        .lineLimit(4...)
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                        onSave()
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!viewModel.canSave)
                }
            }
    }

    @ViewBuilder
    private func photoThumbnail(_ image: Image, onRemove: @escaping () -> Void) -> some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(alignment: .topTrailing) {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white, .black.opacity(0.6))
                        .padding(4)
                }
            }
    }
}

#Preview("Add") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, ListingPhoto.self, configurations: config)
    NavigationStack {
        ListingFormView(type: .add(.flat), viewModel: ListingsViewModel(modelContext: container.mainContext))
    }
}

#Preview("Edit") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, ListingPhoto.self, configurations: config)
    let listing = HouseListing(address: "123 Main St", price: 450000, rating: 4, notes: "Nice garden")
    NavigationStack {
        ListingFormView(type: .edit(listing), viewModel: ListingsViewModel(modelContext: container.mainContext))
    }
}
