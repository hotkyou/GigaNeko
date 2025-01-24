import SwiftUI
import Combine

class FurnitureViewModel: ObservableObject {
    @Published var availablePoints: Int = 0
    @Published var selectedItem: FurnitureItem?
    @Published var currentIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()

    // Lazyプロパティで初期化を簡潔化
    lazy var furnitureItems: [FurnitureItem] = [
        FurnitureItem(
            name: "招き猫",
            level: GiganekoPoint.shared.manekineko,
            imageName: "MabekiNeko",
            effect: GiganekoPoint.shared.addPoint,
            pointCost: GiganekoPoint.shared.mlevelUp
        ),
        FurnitureItem(
            name: "キャットタワー",
            level: GiganekoPoint.shared.catTower,
            imageName: "CatTower",
            effect: GiganekoPoint.shared.addLike,
            pointCost: GiganekoPoint.shared.clevelUp
        ),
        FurnitureItem(
            name: "宝箱",
            level: GiganekoPoint.shared.treasure,
            imageName: "TreasureBox",
            effect: GiganekoPoint.shared.addPresents,
            pointCost: GiganekoPoint.shared.tlevelUp
        )
    ]

    init() {
        // GiganekoPointの変更を監視
        GiganekoPoint.shared.$currentPoints
            .assign(to: &$availablePoints)

        // 初期選択項目の設定
        selectedItem = furnitureItems.first
    }

    func nextItem() {
        guard currentIndex < furnitureItems.count - 1 else { return }
        currentIndex += 1
        updateSelectedItem()
    }

    func previousItem() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        updateSelectedItem()
    }

    private func updateSelectedItem() {
        selectedItem = furnitureItems[currentIndex]
    }
}
