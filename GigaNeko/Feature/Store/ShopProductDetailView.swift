import SwiftUI

struct ShopProductDetailView: View {
    let product: ShopProduct
    @Binding var isShowing: Bool
    let onPurchase: () -> Void
    @StateObject var giganekoPoint = GiganekoPoint.shared
    @StateObject private var purchaseManager = PurchaseManager()
    
    private var canPurchase: Bool {
        product.category == .points || giganekoPoint.currentPoints >= product.price
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Product Image
            ZStack {
                if product.category == .points {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.yellow.opacity(0.15))
                }
                
                Image(product.image)
                    .resizable()
                    .scaledToFit()
                    .padding(24)
            }
            .frame(width: 160, height: 160)
            
            // Product Info
            Text(product.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(product.description)
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)
            
            if !product.subText.isEmpty {
                Text(product.subText)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Price and Purchase Button
            VStack(spacing: 16) {
                HStack {
                    if product.category != .points {
                        Image("Point")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Text("\(product.price)")
                            .font(.title3)
                            .fontWeight(.bold)
                    } else {
                        Text("￥\(product.price)")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }
                
                Button(action: {
                    if product.category == .points {
                        purchaseManager.onPurchaseSuccess = {
                            giganekoPoint.billingPoints(index: product.id)
                        }
                        purchaseManager.purchaseProduct(productId: product.productId)
                    } else {
                        onPurchase()
                    }
                }) {
                    HStack {
                        Text(canPurchase ? (product.category == .points ? "チャージする" : "購入する") : "ポイントが足りません")
                            .fontWeight(.bold)
                        if canPurchase {
                            Image(systemName: "cart.fill")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding(.vertical, 12)
                    .background(canPurchase ? Color.yellow : Color.gray)
                    .cornerRadius(25)
                }
                .disabled(!canPurchase || purchaseManager.isProcessingPayment)
            }
            
            // Close Button
            Button(action: { withAnimation { isShowing = false } }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(radius: 8)
        .padding(.horizontal, 20)
    }
}
