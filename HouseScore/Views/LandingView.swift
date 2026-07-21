import SwiftUI
import SwiftData

struct LandingView: View {
    let viewModel: ListingsViewModel
    let onContinue: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Text("What did you see today?")
                        .font(.title2.bold())
                    Text("Pick a type to add a listing, or skip to your list")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                VStack(spacing: 16) {
                    ForEach(PropertyType.allCases) { type in
                        NavigationLink(value: ListingFormType.add(type)) {
                            Label(type.displayName, systemImage: type.symbolName)
                                .font(.title3.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }
                .padding(.horizontal)

                Spacer()

                Button("Skip to All Listings", action: onContinue)
                    .padding(.bottom)
            }
            .navigationDestination(for: ListingFormType.self) { type in
                ListingFormView(type: type, viewModel: viewModel, onSave: onContinue)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    LandingView(viewModel: ListingsViewModel(modelContext: container.mainContext), onContinue: {})
}
