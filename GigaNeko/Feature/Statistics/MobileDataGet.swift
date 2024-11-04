//
//  MobileDataGet.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI
import Foundation
import Darwin

struct MobileDataGetView: View {
    @State private var wifi: UInt64 = 0
    @State private var wwan: UInt64 = 0
    
    var body: some View {
        VStack {
            Text("Wi-Fi: \(wifi) byte")
            Text("WWAN (Mobile): \((wwan)) byte")
            Text("Time: \(upTime())")
        }
        .padding()
        .onAppear {
            wifi = SystemDataUsage.wifiCompelete
            wwan = SystemDataUsage.wwanCompelete
        }
    }
    
    // バイト数をギガバイトに変換する関数
    func convertToGB(bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_000_000_000
        return String(format: "%.2f", gb)  // 小数点以下2桁まで表示
    }
    
    func upTime() -> String {
        let uptime:TimeInterval = ProcessInfo().systemUptime
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.unitsStyle = .full
        dateFormatter.allowedUnits = [.hour, .minute, .second]
        return dateFormatter.string(from: uptime)!
    }
}

#Preview {
    MobileDataGetView()
}
