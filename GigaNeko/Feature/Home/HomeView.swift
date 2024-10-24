import SwiftUI

struct HomeView: View {
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
                let screenWidth = geometry.size.width
                let leftPadding = 30.0 // 左側の隙間を定義

                // ギガ表示のZStack
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .opacity(0.5)
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
                                .opacity(0.5)
                                .cornerRadius(20)
                            
                            // Rectangleの中のテキスト
                            Text("餌の残り時間")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        
                        HStack {
                            Spacer() // 左側にスペースを追加して右寄せにする
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(width: 80, height: 23) // 元の幅を維持
                                    .opacity(0.5)
                                    .cornerRadius(20)
                                
                                // Rectangleの中のテキスト
                                Text("3000pt")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                        }
                        .frame(width: 230) // Text1と同じ幅のコンテナを作成
                    }
                }
                .padding(.trailing, leftPadding)
                .padding(.top, 65)
            }
        }
        .edgesIgnoringSafeArea(.all) // 全画面表示
    }
}

#Preview {
    HomeView()
}
