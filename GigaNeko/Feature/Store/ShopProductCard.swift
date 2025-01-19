import SwiftUI

struct ShopProductCard: View {
    let product: ShopProduct
    let onSelect: (ShopProduct) -> Void
    let giganekoPoint = GiganekoPoint.shared
    
    private var canPurchase: Bool {
        product.category == .points || giganekoPoint.currentPoints >= product.price
    }
    
    var body: some View {
        Button(action: { onSelect(product) }) {
            HStack(spacing: 16) {
                // Product Image
                ZStack {
                    if product.category == .points {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.yellow.opacity(0.15))
                    }
                    
                    Image(product.image)
                        .resizable()
                        .scaledToFit()
                        .padding(12)
                }
                .frame(width: 80, height: 80)
                
                // Product Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(product.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    
                    if product.category != .points {
                        HStack(spacing: 4) {
                            Image("Point")
                                .resizable()
                                .frame(width: 16, height: 16)
                            Text("\(product.price)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black.opacity(0.8))
                        }
                    } else {
                        Text("￥\(product.price)")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Action Buttons
                VStack(alignment: .trailing, spacing: 8) {
                    HStack(spacing: 2) {
                        Text("詳細")
                            .font(.system(size: 10))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    
                    if !canPurchase {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("必要ポイント")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: true, vertical: false)
                            HStack(spacing: 2) {
                                Text("\(product.price - giganekoPoint.currentPoints)")
                                    .font(.system(size: 12, weight: .bold))
                                Text("pt不足")
                                    .font(.system(size: 10))
                            }
                            .foregroundColor(.red)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: product.category == .points ? "creditcard.fill" : "cart.fill")
                                .font(.system(size: 12))
                            Text(product.category == .points ? "チャージ" : "購入")
                                .font(.system(size: 12, weight: .medium))
                                .fixedSize(horizontal: true, vertical: false)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.yellow)
                        .cornerRadius(12)
                    }
                }
                .frame(width: 90)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
