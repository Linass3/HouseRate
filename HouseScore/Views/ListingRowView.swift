import SwiftData
import SwiftUI

struct ListingRowView: View {
    let listing: HouseListing

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let firstPhoto = listing.photos.min(by: { $0.createdAt < $1.createdAt }),
               let img = UIImage(data: firstPhoto.imageData) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(listing.address)
                    .font(.headline)

                Text(listing.propertyType.displayName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    ratingStars

                    Spacer()

                    if let price = listing.price {
                        Text(price, format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Text(listing.visitedAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }

    private var ratingStars: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= listing.rating ? "star.fill" : "star")
                    .foregroundStyle(.orange)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, ListingPhoto.self, configurations: config)
    let listing = HouseListing(address: "123 Main St", price: 450000, rating: 4, notes: "Nice garden")
    List { ListingRowView(listing: listing) }
        .modelContainer(container)
}
