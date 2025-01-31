//
//  LaunchScreenView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2025/01/10.
//

import SwiftUI

struct LaunchScreenView: View {
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            ZStack {
                Image("LunchScreenImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill) // .fitから.fillに変更
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // 画面いっぱいに表示
                    .ignoresSafeArea() // 画像もセーフエリアを無視
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        isLoading = false
                    }
                }
            }
        } else {
            MainTabView()
        }
    }
}

#Preview {
    LaunchScreenView()
}
