//
//  MobileDataGet.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI
import Foundation
import Darwin

struct MobailDataGetView: View {
    @State private var wifiSent: UInt64 = 0
    @State private var wifiReceived: UInt64 = 0
    @State private var wwanSent: UInt64 = 0
    @State private var wwanReceived: UInt64 = 0
    
    var body: some View {
        VStack {
            Text("Wi-Fi Sent: \(convertToGB(bytes: wifiSent)) GB")
            Text("Wi-Fi Received: \(convertToGB(bytes: wifiReceived)) GB")
            Text("WWAN (Mobile) Sent: \(convertToGB(bytes: wwanSent)) GB")
            Text("WWAN (Mobile) Received: \(convertToGB(bytes: wwanReceived)) GB")
        }
        .padding()
        .onAppear {
            let counters = getDataCounters()
            wifiSent = counters[0]
            wifiReceived = counters[1]
            wwanSent = counters[2]
            wwanReceived = counters[3]
        }
    }
    
    // データカウンタを取得する関数
    func getDataCounters() -> [UInt64] {
        var WiFiSent: UInt64 = 0
        var WiFiReceived: UInt64 = 0
        var WWANSent: UInt64 = 0
        var WWANReceived: UInt64 = 0
        
        var addrs: UnsafeMutablePointer<ifaddrs>?
        
        // ネットワークインターフェース情報の取得
        if getifaddrs(&addrs) == 0, let firstAddr = addrs {
            var cursor: UnsafeMutablePointer<ifaddrs>? = firstAddr
            
            while cursor != nil {
                let name = String(cString: cursor!.pointee.ifa_name)
                
                if cursor!.pointee.ifa_addr.pointee.sa_family == UInt8(AF_LINK) {
                    // ifa_dataがnilでないことを確認
                    if let data = cursor!.pointee.ifa_data {
                        let networkData = unsafeBitCast(data, to: UnsafeMutablePointer<if_data>.self).pointee
                        
                        // Wi-Fiインターフェース (en)
                        if name.hasPrefix("en") {
                            WiFiSent += UInt64(networkData.ifi_obytes)
                            WiFiReceived += UInt64(networkData.ifi_ibytes)
                        }
                        
                        // WWANインターフェース (pdp_ip)
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
    
    // バイト数をギガバイトに変換する関数
    func convertToGB(bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_000_000_000
        return String(format: "%.2f", gb)  // 小数点以下2桁まで表示
    }
}

#Preview {
    MobailDataGetView()
}
