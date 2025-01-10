import SwiftUI

struct FurnitureView: View {
    @StateObject private var viewModel = FurnitureViewModel()
    
    @EnvironmentObject var pointSystem: PointSystem
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: Constants.mainGradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Points Display
                HStack {
                    Spacer()
                    PointsView(points: viewModel.availablePoints)
                }
                .padding(.top, 8)
                
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
                .padding(.vertical, 32)
                
                // Page Indicator
                PageIndicator(
                    currentPage: viewModel.currentIndex,
                    totalPages: viewModel.furnitureItems.count
                )
                
                // Detail View
                if let item = viewModel.selectedItem {
                    FurnitureDetailView(item: item) {
                        if viewModel.availablePoints >= item.pointCost {
                            viewModel.availablePoints -= item.pointCost
                        }
                    }
                }
            }
        }
    }
