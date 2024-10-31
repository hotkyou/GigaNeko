import Foundation
import Darwin

class DataUsageManager {
    static func getDataUsage() -> [UInt64] {
        var WiFiSent: UInt64 = 0
        var WiFiReceived: UInt64 = 0
        var WWANSent: UInt64 = 0
        var WWANReceived: UInt64 = 0
        
        var addrs: UnsafeMutablePointer<ifaddrs>?
        
        if getifaddrs(&addrs) == 0, let firstAddr = addrs {
            var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddr
            while cursor != nil {
                let name = String(cString: cursor!.pointee.ifa_name)
                
                if cursor!.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                    if let data = cursor!.pointee.ifa_data {
                        let networkData = unsafeBitCast(data, to: UnsafeMutablePointer<if_data>.self).pointee
                        
                        if name.hasPrefix("en") {
                            WiFiSent += UInt64(networkData.ifi_obytes)
                            WiFiReceived += UInt64(networkData.ifi_ibytes)
                        }
                        if name.hasPrefix("pdp_ip") {
                            WWANSent += UInt64(networkData.ifi_obytes)
                            WWANReceived += UInt64(networkData.ifi_ibytes)
                        }
                    }
                }
                
                cursor = cursor!.pointee.ifa_next
            }
            
            freeifaddrs(addrs)
        }
        
        return [WiFiSent, WiFiReceived, WWANSent, WWANReceived]
    }
    
    // データを保存する関数
    static func saveDataUsage(_ dataUsage: [UInt64]) {
        UserDefaults.standard.set(dataUsage[0], forKey: "wifiSent")
        UserDefaults.standard.set(dataUsage[1], forKey: "wifiReceived")
        UserDefaults.standard.set(dataUsage[2], forKey: "wwanSent")
        UserDefaults.standard.set(dataUsage[3], forKey: "wwanReceived")
    }
    
    // 保存されたデータを読み込む関数
    static func loadSavedDataUsage() -> [UInt64] {
        let wifiSent = UserDefaults.standard.object(forKey: "wifiSent") as? UInt64 ?? 0
        let wifiReceived = UserDefaults.standard.object(forKey: "wifiReceived") as? UInt64 ?? 0
        let wwanSent = UserDefaults.standard.object(forKey: "wwanSent") as? UInt64 ?? 0
        let wwanReceived = UserDefaults.standard.object(forKey: "wwanReceived") as? UInt64 ?? 0
        
        return [wifiSent, wifiReceived, wwanSent, wwanReceived]
    }
}
