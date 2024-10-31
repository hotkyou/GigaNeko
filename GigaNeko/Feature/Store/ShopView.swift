//
//  StoreView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct ShopView: View {
    
    let products = [
        ("普通の餌", 0),
        ("猫缶", 100),
        ("刺身", 200),
        ("またたび", 900)
    ]
    
    let columns = [
        GridItem(.flexible(minimum: 120)), // カラム幅を固定
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    var body: some View {
        ZStack{
            //カラーストップのグラデーション
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 225/255, green: 255/255, blue: 203/255), // #E1FFCB
                    Color(red: 255/255, green: 242/255, blue: 209/255)  // #FFF2D1
                ]),
                startPoint: .top,
                endPoint: .bottom
            ).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack{
                    Spacer()
                    
                    HStack{
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3)) // グレーの背景
                            .frame(width: 30, height: 30) // サイズ調整
                            .padding(.leading, 10) // 左側に少し余白
                        
                        Text("3600")
                            .font(.system(size: 24, weight: .medium)) // フォントサイズとスタイル
                            .foregroundColor(.gray) // 文字色
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 50) // 全体の高さを設定
                    .background(Color(.white))
                    .cornerRadius(12) // 全体の角丸
                    .padding() // 全体に少し余白
                } // HStack
                
                VStack{
                    HStack(spacing: 20){
                        Text("えさ")
                        Text("おもちゃ")
                        Text("プレゼント")
                        Text("ポイント")
                    }.padding()
                    
                    ScrollView {
                        HStack {
                            Divider()
                                .frame(width: 150, height: 1) // 左側の線の幅を指定
                                .background(Color.gray) // 線の色を設定
                            
                            Text("えさ")
                                .padding(.horizontal, 8) // テキストの左右に余白を追加
                            
                            Divider()
                                .frame(width: 150, height: 1) // 右側の線の幅を指定
                                .background(Color.gray)
                        }


                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(products, id: \.0) { product in
                                ProductView(productName: product.0, productPrice: product.1)
                            }
                        }
                        
                        HStack {
                            Divider()
                                .frame(width: 125, height: 1) // 左側の線の幅を指定
                                .background(Color.gray) // 線の色を設定
                            
                            Text("おもちゃ")
                                .padding(.horizontal, 8) // テキストの左右に余白を追加
                            
                            Divider()
                                .frame(width: 125, height: 1) // 右側の線の幅を指定
                                .background(Color.gray)
                        }
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(products, id: \.0) { product in
                                ProductView(productName: product.0, productPrice: product.1)
                            }
                        }
                        
                        HStack {
                            Divider()
                                .frame(width: 120, height: 1) // 左側の線の幅を指定
                                .background(Color.gray) // 線の色を設定
                            
                            Text("プレゼント")
                                .padding(.horizontal, 8) // テキストの左右に余白を追加
                            
                            Divider()
                                .frame(width: 120, height: 1) // 右側の線の幅を指定
                                .background(Color.gray)
                        }
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(products, id: \.0) { product in
                                ProductView(productName: product.0, productPrice: product.1)
                            }
                        }
                        
                        HStack {
                            Divider()
                                .frame(width: 125, height: 1) // 左側の線の幅を指定
                                .background(Color.gray) // 線の色を設定
                            
                            Text("ポイント")
                                .padding(.horizontal, 8) // テキストの左右に余白を追加
                            
                            Divider()
                                .frame(width: 125, height: 1) // 右側の線の幅を指定
                                .background(Color.gray)
                        }
                        
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(products, id: \.0) { product in
                                ProductView(productName: product.0, productPrice: product.1)
                            }
                        }
                    }
                }
                .background(Color.white)
                
            }.padding(.horizontal,64) // VStack
        }// Zstack
    }
}

#Preview {
    ShopView()
}
