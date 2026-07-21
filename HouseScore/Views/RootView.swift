import SwiftUI
import SwiftData

struct RootView: View {
    private enum Stage {
        case landing
        case listings
    }

    @State
    private var viewModel: ListingsViewModel

    @State
    private var stage: Stage = .landing

    init(modelContext: ModelContext) {
        _viewModel = State(wrappedValue: ListingsViewModel(modelContext: modelContext))
    }

    var body: some View {
        switch stage {
        case .landing:
            LandingView(
                viewModel: viewModel,
                onContinue: { stage = .listings }
            )
        case .listings:
            ListingsView(viewModel: viewModel)
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: HouseListing.self, configurations: config)
    RootView(modelContext: container.mainContext)
}
