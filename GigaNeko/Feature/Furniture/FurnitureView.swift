//
//  FurnitureView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/24.
//

import SwiftUI

struct FurnitureView: View {
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
            
            VStack{
                
                HStack{
                    Spacer()
                    
                    HStack{
                        Image("Point")
                            .resizable()
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
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) { // アイテムを横に並べる
                        ForEach(0..<3) { index in
                            // アイテム
                            VStack{
                                Image("MabekiNeko")
                                    .resizable()
                                    .frame(width: 300, height: 300)
                                    
                                Spacer()
                                    .frame(height: 10)
                              
                            } // VStack
                            .padding(.horizontal,50)
                        }

                    }// HStack
                    
                } // ScrollView
                .padding(.bottom,20)
                
                VStack{
                    // Handle at the top
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray)
                        .frame(width: 90, height: 5)
                        .padding(.top, 10)
                    
                    HStack{
                        Text("LV.3")
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                        
                        Text("招き猫")
                            .font(.title)
                            .bold()
                            .foregroundColor(.black)
                        
                    }
                    .padding(.top,20)
                    .padding(.bottom,20)
                    
                    
                    Text("ストレス値耐性Up!!")
                        .padding(.top,20)
                        .padding(.bottom,50)
            
                    
                    Button(action: {
                        // ボタンが押されたときのアクション
                        print("Button tapped")
                    }) {
                        HStack {
                            // 左側の四角いアイコン
                            Image("Point")
                                .resizable()
                                .frame(width: 30, height: 30)
                            Text("3000pt")
                                .font(.system(size: 18, weight: .medium)) // フォントスタイル
                                .foregroundColor(.black) // 文字色
                        }
                        .padding() // ボタン内のパディング
                        .background(Color(red: 235/255, green: 235/255, blue: 224/255)) // ボタン背景の色
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                    
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity)
                .background(Color.white)
                .cornerRadius(40)
                .shadow(radius: 5)
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

#Preview {
    FurnitureView()
}
