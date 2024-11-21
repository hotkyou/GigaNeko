import SwiftUI

struct HomeView: View {
    @State private var offsetY: CGFloat = 0
    @State private var movingDown = true
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack { // NavigationViewで全体をラップ
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    Image("HomeBackGroundImage")
                        .resizable()
                        .scaledToFit()
                        .frame(height: geometry.size.height)
                        .offset(x: 0, y: 0)
                }
                HStack {
                    let leftPadding = 30.0
                    
                    // ギガ表示のZStack
                    NavigationLink(destination: StatisticsView()) {
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: 80, height: 80)
                                .opacity(0.7)
                                .cornerRadius(20)
                            
                            Text("5")
                                .foregroundColor(.gray)
                                .font(.system(size: 50))
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Text("GB")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 18))
                                        .padding(5)
                                }
                            }
                            .frame(width: 80, height: 80)
                        }
                        .padding(.leading, leftPadding)
                        .padding(.top, 65)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        VStack(spacing: 20) {
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 230, height: 34)
                                    .opacity(0.7)
                                    .cornerRadius(20)
                                
                                HStack {
                                    Spacer()
                                    Image("Stamina")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .offset(x: 0, y: 0)
                                    VStack(alignment: .leading) {
                                        Text("あと 12:40")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 9))
                                        ProgressView(value: 0.5)
                                            .scaleEffect(x: 1, y: 2)
                                    }
                                    Spacer()
                                    Divider()
                                    Spacer()
                                    Image("Stress")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    VStack(alignment: .leading) {
                                        Text("ストレス値")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 9))
                                        ProgressView(value: 0.5)
                                            .scaleEffect(x: 1, y: 2)
                                    }
                                    Spacer()
                                }
                                .frame(width: 230, height: 34)
                            }
                            
                            HStack {
                                Spacer()
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 80, height: 23)
                                        .opacity(0.7)
                                        .cornerRadius(20)
                                    
                                    HStack {
                                        Image("Point")
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                        Text("3000pt")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 12))
                                    }
                                }
                            }
                            .frame(width: 230)
                        }
                    }
                    .padding(.trailing, leftPadding)
                    .padding(.top, 65)
                }
                
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image("Neko")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 300)
                            .offset(y: offsetY)
                        Spacer()
                    }
                    Spacer()
                }
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut(duration: 2)) {
                        offsetY = movingDown ? 5 : -20
                        movingDown.toggle()
                    }
                }
                
                VStack {
                    Spacer()
                        .frame(height: UIScreen.main.bounds.height * 0.85)
                    HStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .opacity(0.7)
                                .cornerRadius(20)
                            HStack {
                                Text("Lv100")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                                Divider()
                                    .frame(height: 15)
                                Text("nekopoyo")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                        }
                        .frame(width: 150, height: 25)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .edgesIgnoringSafeArea(.all)
        } // NavigationView
    }
}


#Preview {
    HomeView()
}
