//
//  ProductView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/31.
//

import SwiftUI

struct ProductGrid: View {
    let products: [(String, Int, String, String, String, String)]
    let columns: [GridItem]

    @State private var selectedProduct: (String, Int, String, String, String, String)?
    @State private var showDetail = false
    @State private var isAppearing = false

    var body: some View {
        ZStack {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(products, id: \.0) { product in
                    ProductView(productName: product.0, productPrice: product.1, category: product.2, image: product.3)
                        .onTapGesture {
                            selectedProduct = product
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showDetail = true
                            }
                        }
                }
            }
            .scaleEffect(isAppearing ? 1 : 0.5)
            .opacity(isAppearing ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isAppearing = true
                }
            }

            if showDetail, let product = selectedProduct {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showDetail = false
                        }
                    }

                ProductDetailView(
                    productName: product.0,
                    productPrice: product.1,
                    category: product.2,
                    mainText: product.4,
                    subText: product.5,
                    showDetail: $showDetail
                )
                .scaleEffect(showDetail ? 1 : 0.5)
                .opacity(showDetail ? 1 : 0)
                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showDetail)
            }
        }
    }
}


struct ProductView: View {
    let productName: String
    let productPrice: Int
    let category: String
    let image: String
    
    var body: some View {
        VStack(spacing: 15) {
            Image(image)
                .resizable()
                .frame(width: 100, height: 100)
            
            Text(productName)
                .font(.body)
            
            HStack {
                if category != "points"{
                    Image("Point")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .padding(.leading, 4)
                    
                    Text("\(productPrice)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                }else{
                    Text("￥\(productPrice)")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.horizontal, 5)
                }
            }
            .frame(height: 40)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(5)
            
        }
        .padding()
    }
}

struct ProductDetailView: View {
    let productName: String
    let productPrice: Int
    let category: String
    let mainText: String
    let subText: String
    @Binding var showDetail: Bool
    
    @EnvironmentObject var pointSystem: PointSystem

    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 100)

            Text(productName)
                .font(.title)
                .bold()

            Text(mainText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(subText)
                .font(.footnote)
                .foregroundColor(.red)
                .padding(.horizontal)

            HStack {
                if category != "points"{
                    Text("\(productPrice) pt")
                        .padding(.horizontal)
                }else {
                    Text("￥\(productPrice)")
                        .padding(.horizontal)
                }

                Button("購入") {
                    pointSystem.store(point: productPrice, category: category)
                }
                .padding()
                .background(Color.yellow.opacity(0.8))
                .cornerRadius(10)
            }
            Button(action: {
                withAnimation {
                    showDetail = false
                }
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            }
            .padding(.top, 20)

        }
        .padding()
        .frame(width: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.scale)
    }
}


#Preview {
    let pointSystem = PointSystem() // PointSystemクラスを正しく実装していると仮定

    return ProductGrid(
        products: [
            ("普通の餌", 0, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを24時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
            ("猫缶", 100, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを48時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
            ("刺身", 200, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを72時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます"),
            ("またたび", 900, "feed", "Food", "猫に与えられる餌アイテムです\n空腹ゲージを240時間回復します", "※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます")
        ],
        columns: [GridItem(.flexible(minimum: 120)), GridItem(.flexible(minimum: 120)), GridItem(.flexible(minimum: 120))]
        )
        .environmentObject(pointSystem)      // PointSystemを渡す
}
