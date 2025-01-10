//
//  StoreView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct ShopView: View {
    @EnvironmentObject var pointSystem: PointSystem

    let products = [
        ("普通の餌", 0, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを24時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
        ("猫缶", 100, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを48時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
        ("刺身", 200, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを72時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
        ("またたび", 900, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを240時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます")
    ]
    
    let toys = [
        ("猫じゃらし", 20, "toys", "Food", "ストレス値を20減少させることができます。", ""),
    ]
    
    let presents = [
        ("赤色の袋", 1000, "presents", "Food", "好感度が100上がります", ""),
        ("青色の袋", 5000, "presents", "Food", "好感度が500上がります", ""),
        ("黄色の袋", 8000, "presents", "Food", "好感度が1000上がります", "")
    ]
    
    let points = [
        ("120pt", 160, "points", "Food", "120pt獲得できます", ""),
        ("380pt", 480, "points", "Food", "380pt獲得できます", ""),
        ("800pt", 1000, "points", "Food", "800pt獲得できます", ""),
        ("1200pt", 1500, "points", "Food", "1200pt獲得できます", ""),
        ("2400pt", 3000, "points", "Food", "2400pt獲得できます", ""),
        ("3900pt", 4900, "points", "Food", "3900pt獲得できます", ""),
        ("8000pt", 10000, "points", "Food", "8000pt獲得できます", "")
    ]

    let columns = [
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120)),
        GridItem(.flexible(minimum: 120))
    ]

    var body: some View {
        ZStack {
            Image("Background")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Spacer()
                    HStack {
                        Image("Point")
                            .resizable()
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
                }
                
                HStack {
                    Spacer()
                    HStack {
                        Image("Point")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 10)
                        Button("test"){
                            pointSystem.test()
                        }
                    }
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding()
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
                                ProductGrid(products: products, columns: columns)

                                SectionHeader(title: "おもちゃ", id: "おもちゃ")
                                ProductGrid(products: toys, columns: columns)

                                SectionHeader(title: "プレゼント", id: "プレゼント")
                                ProductGrid(products: presents, columns: columns)

                                SectionHeader(title: "ポイント", id: "ポイント")
                                ProductGrid(products: points, columns: columns)
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 64)
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
    let pointSystem = PointSystem() // PointSystemクラスを正しく実装していると仮定
    ShopView()
        .environmentObject(pointSystem)      // PointSystemを渡す
}
