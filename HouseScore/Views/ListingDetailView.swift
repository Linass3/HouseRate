import SwiftUI
import SwiftData

struct ListingDetailView: View {
    let listing: HouseListing
    let viewModel: ListingsViewModel

    var body: some View {
        List {
            if !listing.photos.isEmpty {
                let sorted = listing.photos.sorted(by: { $0.createdAt < $1.createdAt })
                Section {
                    if sorted.count == 1, let img = UIImage(data: sorted[0].imageData) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(sorted) { photo in
                                    if let img = UIImage(data: photo.imageData) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 260, height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color(.systemGroupedBackground))
                .listSectionSeparator(.hidden)
            }

            Section("Property") {
                LabeledContent("Type", value: listing.propertyType.displayName)
                LabeledContent("Address", value: listing.address)

                if let price = listing.price {
                    LabeledContent("Price") {
                        Text(price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                    }
                }

                LabeledContent("Visited") {
                    Text(listing.visitedAt, style: .date)
                }
            }

            if listing.contactPhone != nil || listing.listingURL != nil {
                Section("Contact") {
                    if let phone = listing.contactPhone {
                        Link(phone, destination: URL(string: "tel:\(phone.filter { !$0.isWhitespace })")!)
                    }
                    if let urlString = listing.listingURL {
                        let url = URL(string: urlString.hasPrefix("http") ? urlString : "https://\(urlString)")!
                        Link(urlString, destination: url)
                    }
                }
            }

            Section("Your Review") {
                LabeledContent("Rating") {
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= listing.rating ? "star.fill" : "star")
                                .foregroundStyle(.orange)
                        }
                    }
                }

                if !listing.notes.isEmpty {
                    Text(listing.notes)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(listing.address)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: ListingsRoute.form(.edit(listing))) {
                    Text("Edit")
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    let listing = HouseListing(address: "123 Main St", price: 450000, rating: 4, notes: "Nice garden, needs work on the roof.")
    let vm = ListingsViewModel(modelContext: container.mainContext)
    NavigationStack {
        ListingDetailView(listing: listing, viewModel: vm)
    }
}
