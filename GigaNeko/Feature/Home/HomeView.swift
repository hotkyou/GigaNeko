//
//  HomeView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                Image("HomeBackGroundImage")
                    .resizable()
                    .scaledToFit() // 縦に収まるように表示
                    .frame(height: geometry.size.height) // 縦のサイズを画面いっぱいに
                    .offset(x: 0, y: 0) // オフセットを指定し、上部分を表示
            }
            HStack {
                ZStack {    //○ギガ表示
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .opacity(0.5)
                        .cornerRadius(20)
                    
                    // メインのテキスト
                    Text("5")
                        .foregroundColor(.gray)
                        .font(.system(size: 50))
                    
                    // 右下に配置する小さいテキスト
                    VStack {
                        Spacer() // 右下に配置するためにスペースを追加
                        HStack {
                            Spacer()
                            Text("GB")
                                .foregroundColor(.gray)
                                .font(.system(size: 18))
                                .padding(5) // 右下に余白を追加
                        }
                    }
                    .frame(width: 80, height: 80) // 同じ大きさのフレームで配置を制御
                }
                .padding(.top, 65)
                .padding(.leading, 30)
            }
        }
        .edgesIgnoringSafeArea(.all) // 全画面表示
    }
}

#Preview {
    HomeView()
}
