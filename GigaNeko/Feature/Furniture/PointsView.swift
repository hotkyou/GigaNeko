import SwiftUI

struct PointsView: View {
    let points: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Image("Point")
                .resizable()
                .frame(width: 24, height: 24)
                .shadow(color: Constants.Colors.accent.opacity(0.3), radius: 2)
            
            Text("\(points)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Constants.Colors.text.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                .fill(Constants.Colors.background)
                .shadow(color: Constants.Shadows.medium, radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
    }
}
