import SwiftUI

class FurnitureViewModel: ObservableObject {
    let giganekoPoint = GiganekoPoint.shared
    @Published var availablePoints: Int = 0 // 初期値を設定
    @Published var selectedItem: FurnitureItem?
    @Published var currentIndex: Int = 0
    @Published var furnitureItems: [FurnitureItem] = [] // 空で初期化

    init() {
        // インスタンスの初期化後にfurnitureItemsを設定
        furnitureItems = [
            FurnitureItem(
                name: "招き猫",
                level: giganekoPoint.manekineko,
                imageName: "MabekiNeko",
                effect: giganekoPoint.addPoint,
                pointCost: giganekoPoint.mlevelUp
            ),
            FurnitureItem(
                name: "キャットタワー",
                level: giganekoPoint.catTower,
                imageName: "CatTower",
                effect: giganekoPoint.addLike,
                pointCost: giganekoPoint.clevelUp
            ),
            FurnitureItem(
                name: "宝箱",
                level: giganekoPoint.treasure,
                imageName: "TreasureBox",
                effect: giganekoPoint.addPresents,
                pointCost: giganekoPoint.tlevelUp
            )
        ]

        // その他の初期化処理
        availablePoints = giganekoPoint.currentPoints
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
