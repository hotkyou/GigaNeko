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
            let counters = DataUsageManager.loadSavedDataUsage()
            wifiSent = counters[0]
            wifiReceived = counters[1]
            wwanSent = counters[2]
            wwanReceived = counters[3]
        }
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
