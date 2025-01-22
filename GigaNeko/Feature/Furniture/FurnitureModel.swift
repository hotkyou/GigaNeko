import SwiftUI

struct FurnitureItem: Identifiable {
    let id = UUID()
    let name: String
    let level: Int
    let imageName: String
    let effect: String
    let pointCost: Int
}
