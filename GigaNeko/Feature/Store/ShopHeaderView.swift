import SwiftUI

struct ShopHeaderView: View {
    let giganekoPoint = GiganekoPoint.shared
    
    var body: some View {
        HStack {
            Text("Shop")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack(spacing: 8) {
                Image("Point")
                    .resizable()
                    .frame(width: 24, height: 24)
                Text("\(giganekoPoint.currentPoints)")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2, x: 0, y: 2)
        }
    }
}
