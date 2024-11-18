//
//  TabView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedItem = 0
    
    var body: some View {
        TabView(selection:$selectedItem){
            HomeView()
                .tabItem{
                    Image(systemName: "house")
                    Text("Home")
                } .tag(0)
            FurnitureView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Word")
                }.tag(1)
            ShopView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Event")
                }.tag(2)
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("setting")
                }.tag(4)
        }
    }
}


#Preview {
    MainTabView()
}
