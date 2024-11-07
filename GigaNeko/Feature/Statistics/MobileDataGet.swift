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
    @State private var time: String = ""
    @State private var launchtime: TimeInterval = 0
    
    var body: some View {
            VStack {
                Text("Wi-Fi: \(wifi) byte")
                Text("WWAN (Mobile): \(wwan) byte")
                Text("NowTime: \(time)")
                Text("launchTime: \(launchtime)")
            }
            .padding()
            .onAppear {
                saveDataUsage()
                let savedData = loadSavedDataUsage()
                wifi = savedData.wifi
                wwan = savedData.wwan
                launchtime = savedData.launchtime
                time = nowTime() // 現在時刻取得
                print("statsが表示されました")
            }
        }
    
    // バイト数をギガバイトに変換する関数
    func convertToGB(bytes: UInt64) -> String {
        let gb = Double(bytes) / 1_000_000_000
        return String(format: "%.2f", gb)  // 小数点以下2桁まで表示
    }
}

#Preview {
    MobileDataGetView()
}
