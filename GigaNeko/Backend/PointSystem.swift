import Foundation

class PointSystem: ObservableObject {
    // 現在のポイント
    @Published var currentPoints: Int = 0 {
        didSet {
            saveToUserDefaults(key: userDefaultsKeyPoints, value: currentPoints)
        }
    }
    
    // アラートメッセージ
    @Published var alertMessage: String? = nil
    
    // 1GBあたりのポイント量
    @Published var pointsPerGB: Double = 0.0 {
        didSet {
            saveToUserDefaults(key: userDefaultsKeyPointsPerGB, value: pointsPerGB)
        }
    }

    // 定数
    private let maxPoints = 3000 // 一ヶ月にもらえる最大のポイント数
    private let billing = [120, 380, 800, 1200, 2400, 3900, 8000] // 課金ポイント量
    private let userDefaultsKeyPoints = "currentPointsKey"
    private let userDefaultsKeyPointsPerGB = "pointsPerGBKey"

    init() {
        // UserDefaultsから値をロード
        currentPoints = loadFromUserDefaults(key: userDefaultsKeyPoints, defaultValue: 0)
        pointsPerGB = loadFromUserDefaults(key: userDefaultsKeyPointsPerGB, defaultValue: 0.0)
    }
    
    // 1GBあたりのポイント量を計算
    func calculatePointsPerGB(settingDataGB: Double) {
        pointsPerGB = Double(maxPoints) / settingDataGB
    }

    // データ使用量に基づくポイント追加
    func calculatePoints(oneMonthData: Double) {
        let points = pointsPerGB * oneMonthData
        currentPoints = min(Int(points), maxPoints)
    }

    // ポイントを消費
    func consumePoints(consumptionPoints: Int) {
        guard consumptionPoints <= currentPoints else {
            alertMessage = "使用ポイントが不足しています。現在のポイント: \(currentPoints)"
            return
        }
        currentPoints -= consumptionPoints
        alertMessage = nil
    }
    
    // ミッションによるポイント付与
    func missionPoints() {
        currentPoints += 5
    }
    
    // 課金ポイント付与
    func billingPoints(index: Int) {
        guard billing.indices.contains(index) else {
            alertMessage = "無効な課金プランです。"
            return
        }
        currentPoints += billing[index]
    }
    
    // UserDefaults保存メソッド
    private func saveToUserDefaults<T>(key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // UserDefaults読み込みメソッド
    private func loadFromUserDefaults<T>(key: String, defaultValue: T) -> T {
        return UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
    }
}
