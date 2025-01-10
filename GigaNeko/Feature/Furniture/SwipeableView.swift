import SwiftUI

struct SwipeableView: View {
    let item: FurnitureItem
    let onSwipeLeft: () -> Void
    let onSwipeRight: () -> Void
    let canSwipeLeft: Bool
    let canSwipeRight: Bool
    
    @GestureState private var dragOffset: CGFloat = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Image(item.imageName)
            .resizable()
            .scaledToFit()
            .frame(width: 280, height: 280)
            .shadow(color: Constants.Shadows.large, radius: 12, x: 0, y: 6)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .stroke(Constants.Colors.primary.opacity(0.2), lineWidth: 1)
            )
            .background(
                RoundedRectangle(cornerRadius: Constants.Layout.cornerRadius)
                    .fill(Constants.Colors.background)
                    .shadow(color: Constants.Shadows.medium, radius: 8, x: 0, y: 4)
            )
            .offset(x: dragOffset)
            .scaleEffect(scale)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onChanged { value in
                        withAnimation(Constants.Animation.spring) {
                            scale = 0.95
                        }
                    }
                    .onEnded { value in
                        let threshold: CGFloat = 50
                        withAnimation(Constants.Animation.spring) {
                            scale = 1.0
                            if value.translation.width < -threshold && canSwipeLeft {
                                onSwipeLeft()
                            } else if value.translation.width > threshold && canSwipeRight {
                                onSwipeRight()
                            }
                        }
                    }
            )
            .animation(Constants.Animation.spring, value: dragOffset)
    }
}
