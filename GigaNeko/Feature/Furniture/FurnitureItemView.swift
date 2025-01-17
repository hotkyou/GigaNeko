import SwiftUI

struct FurnitureItemView: View {
    let item: FurnitureItem
    
    var body: some View {
        Image(item.imageName)
            .resizable()
            .frame(width: 300, height: 300)
            .padding(.horizontal, 50)
    }
}
