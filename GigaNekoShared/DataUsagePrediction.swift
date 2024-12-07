import CoreML
import Foundation

struct UsagePredictionResult {
    let predictedWifi: Double    // GB単位
    let predictedWwan: Double    // GB単位
    let confidence: Double       // 予測の信頼度
    let peakHours: [Int]         // ピーク時間帯
    let isUnusualPattern: Bool   // 通常と異なるパターンかどうか
}

class DataUsagePredictor {
    static let shared = DataUsagePredictor()
    
    // デフォルトの1日あたりの使用量（GB）
    private let defaultDailyUsage = (
        wifi: 1.0,  // 1GB
        wwan: 0.3   // 300MB
    )
    
    func predictEndOfMonth() -> UsagePredictionResult? {
        guard let dataUsageArray = UserDefaults.shared.array(forKey: "dataUsage") as? [[String: Any]] else {
            return createDefaultPrediction()
        }
        
        // 履歴データが少ない場合（例：3日分未満）
        if dataUsageArray.count < 72 { // 24時間 × 3日
            return createDefaultPrediction()
        }
        
        // すべての利用可能なデータを使用
        let allData = dataUsageArray
        
        var totalWifi: Double = 0
        var totalWwan: Double = 0
        var hourlyUsage: [Int: (wifi: Double, wwan: Double)] = [:]
        var weekdayUsage: [Int: (wifi: Double, wwan: Double)] = [:]
        
        let calendar = Calendar.current
        
        // 時間帯ごとと曜日ごとの平均使用量を計算
        for entry in allData {
            guard let date = entry["date"] as? Date,
                  let wifi = entry["wifi"] as? UInt64,
                  let wwan = entry["wwan"] as? UInt64 else {
                continue
            }
            
            let hour = calendar.component(.hour, from: date)
            let weekday = calendar.component(.weekday, from: date)
            
            let currentHourly = hourlyUsage[hour] ?? (wifi: 0, wwan: 0)
            hourlyUsage[hour] = (
                wifi: currentHourly.wifi + Double(wifi),
                wwan: currentHourly.wwan + Double(wwan)
            )
            
            let currentWeekday = weekdayUsage[weekday] ?? (wifi: 0, wwan: 0)
            weekdayUsage[weekday] = (
                wifi: currentWeekday.wifi + Double(wifi),
                wwan: currentWeekday.wwan + Double(wwan)
            )
            
            totalWifi += Double(wifi)
            totalWwan += Double(wwan)
        }
        
        // 1日あたりの平均使用量を計算（GB単位）
        let daysCount = Double(allData.count) / 24.0
        let avgDailyWifi = (totalWifi / daysCount) / (1024 * 1024 * 1024)
        let avgDailyWwan = (totalWwan / daysCount) / (1024 * 1024 * 1024)
        
        // 月末までの残り日数を計算
        let now = Date()
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                             to: calendar.startOfMonth(for: now)) else {
            return nil
        }
        
        let remainingDays = calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 0
        
        // 曜日ごとの使用パターンを考慮した予測
        var predictedWifi: Double = 0
        var predictedWwan: Double = 0
        
        for day in 0..<remainingDays {
            let futureDate = calendar.date(byAdding: .day, value: day, to: now)!
            let weekday = calendar.component(.weekday, from: futureDate)
            let avgWeekdayUsage = weekdayUsage[weekday] ?? (wifi: avgDailyWifi * (1024 * 1024 * 1024), wwan: avgDailyWwan * (1024 * 1024 * 1024))
            
            let weekdayFactor: Double = (weekday == 1 || weekday == 7) ? 1.2 : 1.0 // 週末は20%増
            
            predictedWifi += (avgWeekdayUsage.wifi / (1024 * 1024 * 1024)) * weekdayFactor
            predictedWwan += (avgWeekdayUsage.wwan / (1024 * 1024 * 1024)) * weekdayFactor
        }
        
        // 直近の傾向を反映
        let recentTrend = calculateRecentTrend(from: allData)
        predictedWifi *= recentTrend.wifi
        predictedWwan *= recentTrend.wwan
        
        // ピーク時間を特定
        let peakHours = hourlyUsage
            .sorted { $0.value.wifi + $0.value.wwan > $1.value.wifi + $1.value.wwan }
            .prefix(3)
            .map { $0.key }
        
        // 通常パターンとの比較（20%以上の増加を異常とみなす）
        let isUnusual = (predictedWifi + predictedWwan) > (avgDailyWifi + avgDailyWwan) * Double(remainingDays) * 1.2
        
        return UsagePredictionResult(
            predictedWifi: predictedWifi,
            predictedWwan: predictedWwan,
            confidence: calculateConfidence(dataCount: allData.count),
            peakHours: peakHours,
            isUnusualPattern: isUnusual
        )
    }
    
    // 信頼度の計算（変更なし）
    private func calculateConfidence(dataCount: Int) -> Double {
        if dataCount < 72 { // 3日未満
            return 0.3
        } else if dataCount < 168 { // 1週間未満
            return 0.5
        } else if dataCount < 720 { // 1ヶ月未満
            return 0.7
        } else {
            return 0.9
        }
    }
    
    // 直近の傾向を計算（変更なし）
    private func calculateRecentTrend(from data: [[String: Any]]) -> (wifi: Double, wwan: Double) {
        let recentDays = Array(data.suffix(72)) // 直近3日間
        let previousDays = Array(data.prefix(72)) // 1週間前の3日間
        
        let recentAvg = calculateAverageUsage(from: recentDays)
        let previousAvg = calculateAverageUsage(from: previousDays)
        
        // トレンド係数を計算（1.0が基準）
        let wifiTrend = max(0.8, min(1.2, recentAvg.wifi / previousAvg.wifi))
        let wwanTrend = max(0.8, min(1.2, recentAvg.wwan / previousAvg.wwan))
        
        return (wifi: wifiTrend, wwan: wwanTrend)
    }
    
    private func calculateAverageUsage(from data: [[String: Any]]) -> (wifi: Double, wwan: Double) {
        var totalWifi: Double = 0
        var totalWwan: Double = 0
        
        for entry in data {
            if let wifi = entry["wifi"] as? UInt64,
               let wwan = entry["wwan"] as? UInt64 {
                totalWifi += Double(wifi)
                totalWwan += Double(wwan)
            }
        }
        
        let count = max(1.0, Double(data.count))
        return (wifi: totalWifi / count, wwan: totalWwan / count)
    }
    
    private func createDefaultPrediction() -> UsagePredictionResult {
        let calendar = Calendar.current
        let now = Date()
        
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1),
                                             to: calendar.startOfMonth(for: now)) else {
            return createPredictionWithDays(30)
        }
        
        let remainingDays = calendar.dateComponents([.day], from: now, to: endOfMonth).day ?? 30
        return createPredictionWithDays(remainingDays)
    }
    
    private func createPredictionWithDays(_ days: Int) -> UsagePredictionResult {
        let dataPlan = Double(UserDefaults.shared.integer(forKey: "dataNumber"))
        let defaultWwan = dataPlan > 0 ? (dataPlan / 30.0) : defaultDailyUsage.wwan
        
        return UsagePredictionResult(
            predictedWifi: defaultDailyUsage.wifi * Double(days),
            predictedWwan: defaultWwan * Double(days),
            confidence: 0.3,
            peakHours: [9, 13, 20],
            isUnusualPattern: false
        )
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
