import Foundation

enum CassetteSide: String, CaseIterable {
    case sideA = "SIDE A"
    case sideB = "SIDE B"

    var next: CassetteSide {
        self == .sideA ? .sideB : .sideA
    }
}
