import SwiftUI

struct FurnitureView: View {
    @StateObject var viewModel = FurnitureViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                gradient: Gradient(colors: Constants.mainGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 0) {
                // Points Display
                HStack {
                    Spacer()
                    PointsView(points: viewModel.availablePoints)
                }
                .padding(.top, 8)
                .padding(.horizontal)
                
                Spacer(minLength: 20)
                
                // Main Content
                ZStack {
                    if let currentItem = viewModel.selectedItem {
                        SwipeableView(
                            item: currentItem,
                            onSwipeLeft: { viewModel.nextItem() },
                            onSwipeRight: { viewModel.previousItem() },
                            canSwipeLeft: viewModel.currentIndex < viewModel.furnitureItems.count - 1,
                            canSwipeRight: viewModel.currentIndex > 0
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 350, maxHeight: 350)
                    }
                    
                    // Navigation Buttons
                    HStack {
                        if viewModel.currentIndex > 0 {
                            NavigationButton(
                                icon: "chevron.left",
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.previousItem()
                                    }
                                }
                            )
                        }
                        
                        Spacer()
                        
                        if viewModel.currentIndex < viewModel.furnitureItems.count - 1 {
                            NavigationButton(
                                icon: "chevron.right",
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.nextItem()
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer(minLength: 20)
                
                // Page Indicator
                PageIndicator(
                    currentPage: viewModel.currentIndex,
                    totalPages: viewModel.furnitureItems.count
                )
                
                // Detail View
                if var item = viewModel.selectedItem {
                    FurnitureDetailView(item: item) {
                        if viewModel.availablePoints >= item.pointCost {
                            item.level += 1
                            item.effect += 0.5
                            item.pointCost += 1000
                        }
                    }
                }
            }
            .padding(.bottom, 50)
            
            BannerAd(adUnitID: "ca-app-pub-2291273458039892/3458851555")
                .frame(height: 50)
        }
    }
}
