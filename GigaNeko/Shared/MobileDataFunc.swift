import Foundation

struct SavedDataUsage {
    let wifi: UInt64
    let wwan: UInt64
    let launchtime: TimeInterval
}

// データを保存する関数
func saveDataUsage() {
    let wifi = SystemDataUsage.wifiCompelete
    let wwan = SystemDataUsage.wwanCompelete
    var wifiArray = UserDefaults.standard.array(forKey: "wifi") as? [UInt64] ?? []
    var wwanArray = UserDefaults.standard.array(forKey: "wwan") as? [UInt64] ?? []
    let lastLaunchTime = loadSavedDataUsage().launchtime
    
    print(wifi)
    //再起動チェック
    if launchTime() > lastLaunchTime {
        // 起動時間が前回の起動より長ければ、配列の最後を上書き
        if let lastWifiIndex = wifiArray.indices.last {
            wifiArray[lastWifiIndex] = wifi
        //初回起動、月の初め
        } else {
            wifiArray.append(wifi)
        }
        
        if let lastWwanIndex = wwanArray.indices.last {
            wwanArray[lastWwanIndex] = wwan
        } else {
            wwanArray.append(wwan)
        }
    } else {
        // 起動時間が短ければ配列に追加
        wifiArray.append(wifi)
        wwanArray.append(wwan)
    }
    print(wifiArray)
    
    UserDefaults.standard.set(wifiArray, forKey: "wifi")
    UserDefaults.standard.set(wwanArray, forKey: "wwan")
    UserDefaults.standard.set(launchTime(), forKey: "launchtime")
}


func loadSavedDataUsage() -> SavedDataUsage {
    // UserDefaultsから保存されたデータを取得
    let wifiArray = UserDefaults.standard.object(forKey: "wifi") as? [UInt64] ?? []
    let wwanArray = UserDefaults.standard.object(forKey: "wwan") as? [UInt64] ?? []
    let launchtime = UserDefaults.standard.object(forKey: "launchtime") as? TimeInterval ?? 0
    
    // 配列内のデータ使用量を合計
    let totalWifiUsage = wifiArray.reduce(0, +)
    let totalWwanUsage = wwanArray.reduce(0, +)
    
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

