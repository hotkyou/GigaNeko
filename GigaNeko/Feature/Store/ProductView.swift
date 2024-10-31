//
//  ProductView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/31.
//

import SwiftUI

struct ProductView: View {
    let productName: String
    let productPrice: Int

    var body: some View {
        VStack(spacing: 15) {
            // 上部の四角いボックス
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 100)
            
            // ラベル
            Text(productName)
                .font(.body)
              
            // ステッパー
            HStack{
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.4)) // グレーの背景
                    .frame(width: 25, height: 25) // サイズ調整
                    .padding(.leading, 5) // 左側に少し余白
                
                Text("\(productPrice)")
                    .font(.system(size: 20, weight: .medium)) // フォントサイズとスタイル
                    .foregroundColor(.black) // 文字色
                    .padding(.horizontal,5) // 左側に少し余白
            }
            .frame(height: 40) // 全体の高さを設定
            .background(Color(red: 0.95, green: 0.95, blue: 0.95)) // 外側の背景色を調整
            .cornerRadius(5) // 全体の角丸
            
        }.padding()
    }
}

#Preview {
    ProductView(productName: "普通のエサ", productPrice: 500)
}
