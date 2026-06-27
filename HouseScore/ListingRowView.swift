//
//  ListingRowView.swift
//  HouseScore
//
//  Created by Linas Venclavičius on 12/06/2026.
//

import SwiftData
import SwiftUI

struct ListingRowView: View {
    let listing: HouseListing

    var body: some View {
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
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    let listing = HouseListing(address: "123 Main St", price: 450000, rating: 4, notes: "Nice garden")
    List { ListingRowView(listing: listing) }
        .modelContainer(container)
}
