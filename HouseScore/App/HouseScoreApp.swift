import SwiftUI
import SwiftData

@main
struct HouseScoreApp: App {
    let container: ModelContainer = {
        let schema = Schema([HouseListing.self, ListingPhoto.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView(modelContext: container.mainContext)
        }
        .modelContainer(container)
    }
}
