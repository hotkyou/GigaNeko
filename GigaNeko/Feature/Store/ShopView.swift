import SwiftUI

struct ShopView: View {
    @EnvironmentObject var pointSystem: PointSystem
    @State private var selectedTab = "えさ"
    @State private var selectedProduct: ShopProduct?
    @State private var showingProductDetail = false
    
    private let productData = ShopProductData()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ShopHeaderView()
                ShopTabView(selectedTab: $selectedTab)
                
                ScrollView {
                    VStack(spacing: 12) {
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
                }
            }
            .padding()
            
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
        if product.category == .points || pointSystem.currentPoints >= product.price {
            pointSystem.store(point: product.price, category: product.category.rawValue)
            withAnimation {
                showingProductDetail = false
            }
        }
    }
}
