import Foundation

struct SavedDataUsage {
    let wifi: UInt64
    let wwan: UInt64
    let launchtime: TimeInterval
}

// データを保存する関数
func saveDataUsage() {
    let currentWifi = SystemDataUsage.wifiCompelete
    let currentWwan = SystemDataUsage.wwanCompelete
    let currentDate = Date()
    
    //差を管理しているDB
    var dataUsageArray = UserDefaults.standard.array(forKey: "dataUsage") as? [[String: Any]] ?? []
    //前回の現在データ使用量を管理するDB
    let lastUsageDict = UserDefaults.standard.dictionary(forKey: "lastUsage") ?? [:]
    let previousWifi = lastUsageDict["wifi"] as? UInt64 ?? 0
    let previousWwan = lastUsageDict["wwan"] as? UInt64 ?? 0
    let previousLaunchTime = lastUsageDict["launchtime"] as? TimeInterval ?? 0
    // 現在の起動時間を取得
    let currentLaunchTime = launchTime()
    
    // データの差分を計算
    var wifiDifference: UInt64
    var wwanDifference: UInt64
    
    if currentLaunchTime <  previousLaunchTime {
        print("再起動")
        // 再起動後の処理
        wifiDifference = currentWifi
        wwanDifference = currentWwan
    } else {
        print("通常起動")
        // 通常起動時の処理（差分計算）
        print(previousWifi, previousWwan)
        wifiDifference = currentWifi - previousWifi
        wwanDifference = currentWwan - previousWwan
    }
    
    // 差DBに入れるためのデータ
    let differenceEntry: [String: Any] = ["wifi": wifiDifference, "wwan": wwanDifference, "date": currentDate]
    dataUsageArray.append(differenceEntry)
    UserDefaults.standard.set(dataUsageArray, forKey: "dataUsage")
    
    // 現在の使用量を保存
    let newLastUsage: [String: Any] = ["wifi": currentWifi, "wwan": currentWwan, "launchtime": currentLaunchTime]
    UserDefaults.standard.set(newLastUsage, forKey: "lastUsage")
    
    print("Data Usage Array with Differences: \(dataUsageArray)")
}


// データ構造体
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

// 日ごとに時間単位でデータを取得
func loadHourlyDataUsage(for date: Date) -> [HourlyDataUsage] {
    guard let dataUsageArray = UserDefaults.standard.array(forKey: "dataUsage") as? [[String: Any]] else {
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
    guard let dataUsageArray = UserDefaults.standard.array(forKey: "dataUsage") as? [[String: Any]] else {
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
    guard let dataUsageArray = UserDefaults.standard.array(forKey: "dataUsage") as? [[String: Any]] else {
        return []
    }
    
    let calendar = Calendar.current
    var dailyDataUsage: [DailyDataUsage] = []
    
    // ClosedRangeをRangeに変換
    if let dayRange = calendar.range(of: .day, in: .month, for: date) {
        let range = dayRange.lowerBound..<dayRange.upperBound

        for day in range {
            let dailyData = dataUsageArray.filter { entry in
                if let entryDate = entry["date"] as? Date,
                   calendar.isDate(entryDate, equalTo: date, toGranularity: .month),
                   calendar.component(.day, from: entryDate) == day {
                    return true
                }
                return false
            }
            
            let totalWifi = dailyData.reduce(0) { $0 + ($1["wifi"] as? UInt64 ?? 0) }
            let totalWwan = dailyData.reduce(0) { $0 + ($1["wwan"] as? UInt64 ?? 0) }
            
            dailyDataUsage.append(DailyDataUsage(day: day, wifi: totalWifi, wwan: totalWwan))
        }
    }
    
    return dailyDataUsage
}

func loadSavedDataUsage(for period: Calendar.Component? = nil) -> SavedDataUsage {
    // UserDefaultsから保存されたデータを取得
    guard let dataUsageArray = UserDefaults.standard.array(forKey: "dataUsage") as? [[String: Any]] else {
        return SavedDataUsage(wifi: 0, wwan: 0, launchtime: 0)
    }
    
    let launchtime = UserDefaults.standard.object(forKey: "launchtime") as? TimeInterval ?? 0
    let calendar = Calendar.current
    let currentDate = Date()
    
    var totalWifiUsage: UInt64 = 0
    var totalWwanUsage: UInt64 = 0
    
    for entry in dataUsageArray {
        if let wifi = entry["wifi"] as? UInt64,
           let wwan = entry["wwan"] as? UInt64,
           let date = entry["date"] as? Date {
            
            // 日、月、年ごとのフィルタリング
            if let period = period {
                let isInSamePeriod = calendar.isDate(date, equalTo: currentDate, toGranularity: period)
                if !isInSamePeriod { continue }
            }
            
            // Wi-FiとWWANのデータ使用量を合計
            totalWifiUsage += wifi
            totalWwanUsage += wwan
        }
    }
    
    // 合計したデータ量を表示
    print("総WiFi使用量: \(totalWifiUsage) bytes")
    print("総WWAN使用量: \(totalWwanUsage) bytes")
    
    // 合計データ量を持つSavedDataUsage構造体を返す
    return SavedDataUsage(wifi: totalWifiUsage, wwan: totalWwanUsage, launchtime: launchtime)
}


func resetData() {
    let Wifi: UInt64 = 0
    let Wwan: UInt64 = 0
    
    saveDataUsage()
}

func nowTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return dateFormatter.string(from: Date())
}

func launchTime() -> TimeInterval {
    let uptime:TimeInterval = ProcessInfo().systemUptime
    let dateFormatter = DateComponentsFormatter()
    dateFormatter.unitsStyle = .full
    dateFormatter.allowedUnits = [.hour, .minute, .second]
    //return dateFormatter.string(from: uptime)!
    return uptime
}

func getDayData() -> Int {
    return 100
}

func getWeekData() -> Int {
    return 100
}

func getMonthData() -> Int {
    return 100
}

