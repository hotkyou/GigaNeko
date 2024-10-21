//
//  HomeView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        ZStack {
            // ステータスバー
            HStack(spacing: 10) {
                Text("5")
                    .padding(25) // テキストにパディングを追加
                    .background(
                        Rectangle()
                            .fill(Color.red) // 背景色を赤に設定
                            .frame(width: 75, height: 75)
                            .opacity(0.5)
                            .cornerRadius(20) // 角丸を適用
                    )
                    .padding(.leading, 10) // テキストの左側にパディングを追加
                    .foregroundColor(.white) // テキストの色
                    .font(.system(size: 50))         // テキストのフォントサイズ
                Spacer()
                VStack(alignment: .trailing) {
                        Rectangle()
                            .frame(width: 200, height: 35)
                            .padding(.trailing, 16)
                            .background(
                                
                            )
                        Spacer()
                        Rectangle()
                            .frame(width: 50, height: 35)
                            .padding(.trailing, 16)
                }
                .frame(height: 75)
                .foregroundColor(.green)
                .cornerRadius(10)
            }
            .frame(height: 75)
            .foregroundColor(.white)
        }
        .background(
             //背景画像
            Image("HomeBackGroundImage")
                .resizable()
                .scaledToFill()
                .frame(width: 1193.36, height: 852)
                .offset(x: -400, y: 0)
                .clipped()
        )
    }
}

#Preview {
    HomeView()
}
