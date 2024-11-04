import Foundation

func saveData() -> String {
    return "Hello, World!!"
}

func resetData() {
    let Wifi: UInt64 = 0
    let Wwan: UInt64 = 0
    
    SystemDataUsage.saveDataUsage([Wifi, Wwan])
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

