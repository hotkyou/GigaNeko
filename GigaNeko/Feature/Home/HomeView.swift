import SwiftUI

struct HomeView: View {
    @State private var offsetY: CGFloat = 0
    @State private var movingDown = true
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                Image("HomeBackGroundImage")
                    .resizable()
                    .scaledToFit() // 縦に収まるように表示
                    .frame(height: geometry.size.height) // 縦のサイズを画面いっぱいに
                    .offset(x: 0, y: 0) // オフセットを指定し、上部分を表示
            }
            HStack {
                let leftPadding = 30.0 // 左側の隙間を定義
                
                // ギガ表示のZStack
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .opacity(0.7)
                        .cornerRadius(20)
                    
                    // メインのテキスト
                    Text("5")
                        .foregroundColor(.gray)
                        .font(.system(size: 50))
                    
                    // 右下に配置する小さいテキスト
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
                
                Spacer() // ギガと右のRectangleの間にスペースを入れる
                
                // 餌の残り時間とポイント表示
                HStack { // 新しいHStackを追加
                    Spacer() // 左側にスペースを追加して右寄せにする
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
                                    .offset(x: 0, y: 0) // オフセットを指定し、上部分を表示
                                VStack(alignment: .leading) {
                                    
                                    // Rectangleの中のテキスト
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
                                    
                                    // Rectangleの中のテキスト
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
                            Spacer() // 左側にスペースを追加して右寄せにする
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 23) // 元の幅を維持
                                    .opacity(0.7)
                                    .cornerRadius(20)
                                
                                HStack {
                                    Image("Point")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                    // Rectangleの中のテキスト
                                    Text("3000pt")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                        .frame(width: 230) // Text1と同じ幅のコンテナを作成
                    }
                } // HStack
                .padding(.trailing, leftPadding)
                .padding(.top, 65)
            } // HStack
            
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
                    if movingDown {
                        offsetY = 5
                    } else {
                        offsetY = -20
                    }
                    movingDown.toggle()
                }
            }
            
            VStack {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height * 0.85) // 画面の高さの9/10
                HStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .opacity(0.7)
                            .cornerRadius(20)
                        HStack {
                            Text("Lv100")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            Divider()
                                .frame(height: 15)
                            Text("nekopoyo")
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .font(.system(size: 12))
                            
                        }
                    }
                    .frame(width: 150, height: 25)
                    Spacer()
                }
                Spacer()
            }
            
        } // GeometryReader
        .edgesIgnoringSafeArea(.all) // 全画面表示
    }
}

#Preview {
    HomeView()
}
