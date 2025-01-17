import SwiftUI

struct ShopView: View {
    @EnvironmentObject var pointSystem: PointSystem
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
