import SwiftUI

struct ShopHeaderView: View {
    @StateObject var giganekoPoint = GiganekoPoint.shared
    @State private var showingCommercialLaw = false
    
    var body: some View {
        HStack {
            Text("Shop")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            HStack() {
                LegalLinkButton(title: "特定商取引法\nの表記") {
                    showingCommercialLaw = true
                }
            }
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
        .sheet(isPresented: $showingCommercialLaw) {
            CommercialLawView()
        }
    }
}
