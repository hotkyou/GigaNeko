import Foundation

struct SavedDataUsage {
    let wifi: UInt64
    let wwan: UInt64
    let launchtime: TimeInterval
}

struct HourlyDataUsage {
    var hour: Int
    var wifi: UInt64
    var wwan: UInt64
}

struct DailyDataUsage {
    var day: Int
    var wifi: UInt64
    var wwan: UInt64
}

// データを保存する関数
func saveDataUsage() {
    let currentWifi = SystemDataUsage.wifiCompelete
    let currentWwan = SystemDataUsage.wwanCompelete
    let currentDate = Date()
    
    //差を管理しているDB
    var dataUsageArray = UserDefaults.shared.array(forKey: "dataUsage") as? [[String: Any]] ?? []
    //前回の現在データ使用量を管理するDB
    let lastUsageDict = UserDefaults.shared.dictionary(forKey: "lastUsage") ?? [:]
    let previousWifi = lastUsageDict["wifi"] as? UInt64 ?? 0
    let previousWwan = lastUsageDict["wwan"] as? UInt64 ?? 0
    let previousLaunchTime = lastUsageDict["launchtime"] as? TimeInterval ?? 0
    // 現在の起動時間を取得
    let currentLaunchTime = launchTime()
    
    // データの差分を計算
    var wifiDifference: UInt64
    var wwanDifference: UInt64
    
    if dataUsageArray.isEmpty {
        print("初回起動")
        // 初回起動時は0を記録
        wifiDifference = 0
        wwanDifference = 0
    } else if currentLaunchTime <  previousLaunchTime {
        print("再起動")
        // 再起動後の処理
        wifiDifference = currentWifi
        wwanDifference = currentWwan
    } else {
        print("通常起動")
        // 通常起動時の処理（差分計算）
        print(previousWifi, previousWwan)
        if currentWifi >= previousWifi && currentWwan >= previousWwan {
            // 両方のカウンターが正常な場合
            wifiDifference = currentWifi - previousWifi
            wwanDifference = currentWwan - previousWwan
        } else {
            // 何らかのタイミングで前の値よりも下がった場合
            print("カウンターリセット検出")
            return
        }
    }
    // 差DBに入れるためのデータ
    let differenceEntry: [String: Any] = ["wifi": wifiDifference, "wwan": wwanDifference, "date": currentDate]
    let newLastUsage: [String: Any] = ["wifi": currentWifi, "wwan": currentWwan, "launchtime": currentLaunchTime]
    dataUsageArray.append(differenceEntry)
    
    UserDefaults.shared.set(dataUsageArray, forKey: "dataUsage")
    UserDefaults.shared.set(newLastUsage, forKey: "lastUsage")
    UserDefaults.shared.synchronize()
    
    print("Data Usage Array with Differences: \(dataUsageArray)")
}

// 日ごとに時間単位でデータを取得
func loadHourlyDataUsage(for date: Date) -> [HourlyDataUsage] {
    guard let dataUsageArray = UserDefaults.shared.array(forKey: "dataUsage") as? [[String: Any]] else {
        return []
    }
    
    let calendar = Calendar.current
    var hourlyDataUsage: [HourlyDataUsage] = []
    
    for hour in 0..<24 {
        let hourlyData = dataUsageArray.filter { entry in
            if let entryDate = entry["date"] as? Date,
               calendar.isDate(entryDate, equalTo: date, toGranularity: .day),
               calendar.component(.hour, from: entryDate) == hour {
                return true
            }
            return false
        }
        
        let totalWifi = hourlyData.reduce(0) { $0 + ($1["wifi"] as? UInt64 ?? 0) }
        let totalWwan = hourlyData.reduce(0) { $0 + ($1["wwan"] as? UInt64 ?? 0) }
        
        hourlyDataUsage.append(HourlyDataUsage(hour: hour, wifi: totalWifi, wwan: totalWwan))
    }
    
    return hourlyDataUsage
}

// 週ごとに日単位でデータを取得
func loadWeeklyDataUsage(for date: Date) -> [DailyDataUsage] {
    guard let dataUsageArray = UserDefaults.shared.array(forKey: "dataUsage") as? [[String: Any]] else {
        return []
    }
    
    let calendar = Calendar.current
    var dailyDataUsage: [DailyDataUsage] = []
    
    // 指定された日付の週の日曜日を取得
    guard let sunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
        return []
    }
    
    // 日曜日から土曜日までの7日間のデータを取得
    for dayOffset in 0..<7 {
        guard let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: sunday) else { continue }
        
        // その日のデータをフィルタリング
        let dailyData = dataUsageArray.filter { entry in
            if let entryDate = entry["date"] as? Date {
                return calendar.isDate(entryDate, inSameDayAs: targetDate)
            }
            return false
        }
        
        // その日の合計使用量を計算
        let totalWifi = dailyData.reduce(0) { $0 + ($1["wifi"] as? UInt64 ?? 0) }
        let totalWwan = dailyData.reduce(0) { $0 + ($1["wwan"] as? UInt64 ?? 0) }
        
        // 曜日のインデックス（0=日曜、1=月曜、...、6=土曜）を取得
        let dayIndex = calendar.component(.weekday, from: targetDate) - 1
        
        dailyDataUsage.append(DailyDataUsage(
            day: dayIndex,
            wifi: totalWifi,
            wwan: totalWwan
        ))
    }
    
    // 曜日順（日曜から土曜）でソート
    dailyDataUsage.sort { $0.day < $1.day }
    
    return dailyDataUsage
}

// 月ごとに日単位でデータを取得
func loadMonthlyDataUsage(for date: Date) -> [DailyDataUsage] {
    guard let dataUsageArray = UserDefaults.shared.array(forKey: "dataUsage") as? [[String: Any]] else {
        return []
    }
    
    let calendar = Calendar.current
    
    // 月の初日を取得
    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
          let _ = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
        return []
    }
    
    var dailyDataUsage: [DailyDataUsage] = []
    
    // 月の全日数分のデータを生成
    guard let daysInMonth = calendar.range(of: .day, in: .month, for: date)?.count else {
        return []
    }
    
    for day in 1...daysInMonth {
        // その日の日付を生成
        guard let currentDate = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else {
            continue
        }
        
        // その日のデータをフィルタリング
        let dailyData = dataUsageArray.filter { entry in
            guard let entryDate = entry["date"] as? Date else { return false }
            return calendar.isDate(entryDate, inSameDayAs: currentDate)
        }
        
        // データ使用量を集計
        let totalWifi = dailyData.reduce(0) { $0 + ($1["wifi"] as? UInt64 ?? 0) }
        let totalWwan = dailyData.reduce(0) { $0 + ($1["wwan"] as? UInt64 ?? 0) }
        
        // 1から始まる日付でデータを追加
        dailyDataUsage.append(DailyDataUsage(day: day, wifi: totalWifi, wwan: totalWwan))
    }
    
    return dailyDataUsage
}

func getCurrentMonthUsage() -> (wifi: Double, wwan: Double) {
    let calendar = Calendar.current
    let currentDate = Date()
    
    guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
        return (0, 0)
    }
    
    // 月間データを取得
    let monthlyData = loadMonthlyDataUsage(for: startOfMonth)
    
    // WiFiの合計を計算
    let totalWifi = monthlyData.reduce(0.0) { sum, data in
        sum + (Double(data.wifi) / (1024 * 1024 * 1024))
    }
    
    // モバイルデータの合計を計算
    let totalWwan = monthlyData.reduce(0.0) { sum, data in
        sum + (Double(data.wwan) / (1024 * 1024 * 1024))
    }
    
    return (totalWifi, totalWwan)
}

func launchTime() -> TimeInterval {
    let uptime:TimeInterval = ProcessInfo().systemUptime
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.unitsStyle = .full
    dateFormatter.allowedUnits = [.hour, .minute, .second]
    return uptime
}
