import SwiftUI

struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Constants.Colors.text.opacity(0.7))
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Constants.Colors.background)
                        .shadow(color: Constants.Shadows.medium, radius: 8, x: 0, y: 4)
                )
        }
    }
}
