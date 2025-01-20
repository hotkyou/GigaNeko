import SwiftUI

class FurnitureViewModel: ObservableObject {
    @Published var availablePoints: Int = 3600
    @Published var furnitureItems: [FurnitureItem] = [
        FurnitureItem(
            name: "招き猫",
            level: 1,
            imageName: "MabekiNeko",
            effect: "データ使用時ポイント取得+1%UP",
            pointCost: 3000
        ),
        FurnitureItem(
            name: "キャットタワー",
            level: 1,
            imageName: "CatTower",
            effect: "撫で時好感度+1%UP",
            pointCost: 2500
        ),
        FurnitureItem(
            name: "宝箱",
            level: 1,
            imageName: "TreasureBox",
            effect: "プレゼント時好感度+1%UP",
            pointCost: 1800
        )
    ]
    
    @Published var selectedItem: FurnitureItem?
    @Published var currentIndex: Int = 0
    
    init() {
        selectedItem = furnitureItems.first
    }
    
    func nextItem() {
        if currentIndex < furnitureItems.count - 1 {
            currentIndex += 1
            selectedItem = furnitureItems[currentIndex]
        }
    }
    
    func previousItem() {
        if currentIndex > 0 {
            currentIndex -= 1
            selectedItem = furnitureItems[currentIndex]
        }
    }
}
