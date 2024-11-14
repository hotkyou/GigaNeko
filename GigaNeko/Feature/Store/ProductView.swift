//
//  ProductView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/31.
//

import SwiftUI

struct ProductGrid: View {
    let products: [(String, Int)]
    let columns: [GridItem]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(products, id: \.0) { product in
                ProductView(productName: product.0, productPrice: product.1)
            }
        }
    }
}

struct ProductView: View {
    let productName: String
    let productPrice: Int
    
    var body: some View {
        VStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 100, height: 100)
            
            Text(productName)
                .font(.body)
            
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.4))
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
