import SwiftUI

struct FurnitureDetailView: View {
    let item: FurnitureItem
    let onPurchase: () -> Void
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Title and Level
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Constants.Colors.text)
                }
                
                Spacer()
                
                // Level Badge
                Text("LV.\(item.level)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Constants.Colors.primary, Constants.Colors.secondary]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
            .padding(.top, 20)
            .padding(.horizontal)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
            
            // Effect
            HStack(spacing: 15) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.Colors.accent)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0).repeatForever(),
                        value: isAnimating
                    )
                
                Text(item.effect)
                    .font(.body)
                    .foregroundColor(Constants.Colors.text.opacity(0.8))
            }
            .padding(.vertical, 15)
            
            // Purchase Button
            Button(action: onPurchase) {
                HStack {
                    Text("購入する")
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image("Point")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("\(item.pointCost)")
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: Constants.mainGradient),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(15)
                .shadow(color: Constants.Colors.primary.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            .padding(.bottom, 25)
        }
        .padding(.top)
        .background(
            Rectangle()
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: Constants.Shadows.large, radius: 20, y: -8)
        )
        .onAppear {
            isAnimating = true
        }
    }
}
