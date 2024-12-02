//
//  StoreView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct ShopView: View {
    @ObservedObject var pointSystem: PointSystem // PointSystemを受け取る
    
    let products = [
        ("普通の餌", 0),
        ("猫缶", 100),
        ("刺身", 200),
        ("またたび", 900)
    ]
    
    let columns = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]
    
    var body: some View {
        let storeSystem = StoreSystem(pointSystem: pointSystem)
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 30, height: 30)
                            .padding(.leading, 10)
                        
                        Text("\(pointSystem.currentPoints)")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                    }
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
                    //テストボタン(消す)
                    HStack {
                        Button("test"){
                            pointSystem.test()
                        }
                        .background()
                    }
                }
                
                VStack {
                    ScrollViewReader { proxy in
                        HStack(spacing: 20) {
                            Button("えさ") {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("えさ", anchor: .top)
                                }
                            }
                            Button("おもちゃ") {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("おもちゃ", anchor: .top)
                                }
                            }
                            Button("プレゼント") {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("プレゼント", anchor: .top)
                                }
                            }
                            Button("ポイント") {
                                withAnimation(.easeInOut) {
                                    proxy.scrollTo("ポイント", anchor: .top)
                                }
                            }
                        }
                        .padding()
                        
                        ScrollView {
                            Group {
                                SectionHeader(title: "えさ", id: "えさ")
                                ProductGrid(products: products, columns: columns, storeSystem: storeSystem)
                                
                                SectionHeader(title: "おもちゃ", id: "おもちゃ")
                                ProductGrid(products: products, columns: columns, storeSystem: storeSystem)
                                
                                SectionHeader(title: "プレゼント", id: "プレゼント")
                                ProductGrid(products: products, columns: columns, storeSystem: storeSystem)
                                
                                SectionHeader(title: "ポイント", id: "ポイント")
                                ProductGrid(products: products, columns: columns, storeSystem: storeSystem)
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                
            }.padding(.horizontal, 64)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let id: String
    
    var body: some View {
        HStack {
            Divider().frame(width: 120, height: 1).background(Color.gray)
            Text(title).padding(.horizontal, 8)
            Divider().frame(width: 120, height: 1).background(Color.gray)
        }
        .id(id)
    }
}

#Preview {
    let pointSystem = PointSystem() // PointSystemのインスタンスを作成
    ShopView(pointSystem: pointSystem)
}
