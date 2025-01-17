//
//  TabView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedItem = 0
    let pointSystem = PointSystem()
    
    var body: some View {
        TabView(selection:$selectedItem){
            HomeView()
                .tabItem{
                    Image(systemName: "house")
                    Text("ホーム")
                } .tag(0)
            FurnitureView()
                .tabItem {
                    Image(systemName: "table.furniture")
                    Text("家具")
                }.tag(1)
            ShopView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("ショップ")
                }.tag(2)
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("設定")
                }.tag(4)
        }
        .environmentObject(pointSystem)
    }
}


#Preview {
    MainTabView()
        .environmentObject(PointSystem())
}
