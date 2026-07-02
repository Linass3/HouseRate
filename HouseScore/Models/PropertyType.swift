import Foundation

enum PropertyType: String, Codable, CaseIterable, Identifiable {
    case flat, cottage, house

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .flat:    "Flat"
        case .cottage: "Cottage"
        case .house:   "House"
        }
    }
}
