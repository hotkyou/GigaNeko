import SwiftUI

class FurnitureItem: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    @Published var level: Int
    let imageName: String
    @Published var effect: Double
    @Published var pointCost: Int

    init(name: String, level: Int, imageName: String, effect: Double, pointCost: Int) {
        self.name = name
        self.level = level
        self.imageName = imageName
        self.effect = effect
        self.pointCost = pointCost
    }
}
