import SwiftUI

struct ShopView: View {
    @StateObject var giganekoPoint = GiganekoPoint.shared
    @State private var selectedTab = "えさ"
    @State private var selectedProduct: ShopProduct?
    @State private var showingProductDetail = false
    
    private let productData = ShopProductData()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 255/255, green: 240/255, blue: 245/255),  // 薄いピンク
                    Color(red: 255/255, green: 228/255, blue: 225/255),  // ミスティローズ
                    Color(red: 255/255, green: 245/255, blue: 238/255)   // セピア調
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    ShopHeaderView()
                    ShopTabView(selectedTab: $selectedTab)
                }
                .padding(.horizontal)
                .padding(.top)
                
                ScrollView {
                    VStack(spacing: 12) {
                        if selectedTab == "ポイント" {
                            RewardAdCard()
                        }
                        ForEach(currentProducts) { product in
                            ShopProductCard(
                                product: product,
                                onSelect: { product in
                                    selectedProduct = product
                                    withAnimation {
                                        showingProductDetail = true
                                    }
                                }
                            )
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .padding(.bottom, 50) // BannerAdの高さ分の余白を追加
                }
                
                BannerAd(adUnitID: "ca-app-pub-2291273458039892/9397573945")
                    .frame(height: 50)
            }
            
            if showingProductDetail, let product = selectedProduct {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showingProductDetail = false
                        }
                    }
                
                ShopProductDetailView(
                    product: product,
                    isShowing: $showingProductDetail,
                    onPurchase: { performPurchase(product: product) }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
    
    private var currentProducts: [ShopProduct] {
        switch selectedTab {
        case "えさ":
            return productData.feeds
        case "おもちゃ":
            return productData.toys
        case "プレゼント":
            return productData.presents
        case "ポイント":
            return productData.points
        default:
            return []
        }
    }
    
    private func performPurchase(product: ShopProduct) {
        if product.category == .points || giganekoPoint.currentPoints >= product.price {
            giganekoPoint.store(point: product.price, category: product.category.rawValue)
            withAnimation {
                showingProductDetail = false
            }
        }
    }
}

struct LegalLinkButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}
