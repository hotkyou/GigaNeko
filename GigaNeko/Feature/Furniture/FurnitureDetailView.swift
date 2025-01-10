import SwiftUI

struct FurnitureDetailView: View {
    let item: FurnitureItem
    let onPurchase: () -> Void
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Constants.Layout.spacing) {
            Capsule()
                .fill(Constants.Colors.text.opacity(0.2))
                .frame(width: 40, height: 4)
                .padding(.top, 12)
            
            // レベルとアイテム名
            HStack(spacing: Constants.Layout.spacing) {
                // レベルバッジ
                Text("LV.\(item.level)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Constants.Colors.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Constants.Colors.primary.opacity(0.1))
                    )
                
                // アイテム名
                Text(item.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Constants.Colors.text)
            }
            .padding(.top, 8)
            
            // エフェクト表示
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(Constants.Colors.accent)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0).repeatForever(),
                        value: isAnimating
                    )
                
                Text(item.effect)
                    .font(.system(size: 18))
                    .foregroundColor(Constants.Colors.text.opacity(0.8))
            }
            .padding(.vertical, 8)
            
            // 購入ボタン
            Button(action: onPurchase) {
                HStack(spacing: 16) {
                    Image("Point")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("\(item.pointCost)pt")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: Constants.mainGradient),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius))
                .shadow(color: Constants.Shadows.medium, radius: 10, x: 0, y: 5)
            }
            .padding(.vertical, 16)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(Constants.Colors.background)
                .shadow(color: Constants.Shadows.large, radius: 20, y: -8)
        )
        .onAppear {
            isAnimating = true
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
