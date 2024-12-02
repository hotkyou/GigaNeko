//
//  PrezentView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/11/29.
//

import SwiftUI

struct PrezentGrid: View {
    let products: [(String, Int)]
    let columns: [GridItem]
    
    @State private var selectedProduct: (String, Int)?
    @State private var showDetail = false
    @State private var isAppearing = false // New state for the entire view's animation
    
    var body: some View {
        ZStack {
            // Main product grid with animation for the entire screen
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(products, id: \.0) { product in
                    PrezentView(productName: product.0, productPrice: product.1)
                        .onTapGesture {
                            selectedProduct = product
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                showDetail = true
                            }
                        }
                }
            }
            .scaleEffect(isAppearing ? 1 : 0.5) // Scale effect for the bounce animation
            .opacity(isAppearing ? 1 : 0) // Opacity to fade in
            .onAppear {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    isAppearing = true
                }
            }
            
            // Detail view overlay
            if showDetail, let product = selectedProduct {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            showDetail = false
                        }
                    }
                
                PrezentDetailView(productName: product.0, productPrice: product.1, showDetail: $showDetail)
                    .scaleEffect(showDetail ? 1 : 0.5)
                    .opacity(showDetail ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: showDetail)
            }
        }
    }
}

struct PrezentView: View {
    let productName: String
    let productPrice: Int
    
    var body: some View {
        VStack(spacing: 15) {
            Image("TakaraBako")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text(productName)
                .font(.body)
            
            HStack {
                Image("Point")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.leading, 5)
                
                Text("\(productPrice)")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                    .padding(.horizontal, 5)
            }
            .frame(height: 40)
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .cornerRadius(5)
            
        }
        .padding()
    }
}

struct PrezentDetailView: View {
    let productName: String
    let productPrice: Int
    @Binding var showDetail: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 100)
            
            Text(productName)
                .font(.title)
                .bold()
            
            Text("猫に与えられる餌アイテムです\n空腹ゲージを48時間回復します")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("※ 新しく食べた餌の継続時間は今の継続時間には追加されず上書きされます")
                .font(.footnote)
                .foregroundColor(.red)
                .padding(.horizontal)
            
            HStack {
                Text("\(productPrice) pt")
                    .padding(.horizontal)
                
                Button("購入") {
                    // Add purchase action here
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
