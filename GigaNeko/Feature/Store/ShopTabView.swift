import SwiftUI

struct ShopTabView: View {
    @Binding var selectedTab: String
    let tabs = ["えさ", "おもちゃ", "プレゼント", "ポイント"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    withAnimation {
                        selectedTab = tab
                    }
                }) {
                    Text(tab)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .bold : .medium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .background(selectedTab == tab ? Color.yellow.opacity(0.2) : Color.clear)
                        .cornerRadius(12)
                        .foregroundColor(selectedTab == tab ? .black : .gray)
                }
            }
        }
        .padding(4)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 2, x: 0, y: 2)
    }
}
