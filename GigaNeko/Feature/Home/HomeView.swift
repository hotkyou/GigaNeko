




import SwiftUI

struct HomeView: View {
    @State private var offsetY: CGFloat = 0
    @State private var movingDown = true
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    // スタミナとストレス値
    @State private var stamina: Double = 80
    @State private var stress: Double = 15
    @State private var staminatimer: Timer?
    @AppStorage("lastActiveDate") private var lastActiveDate: Date = Date()
    
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
                                    // 小数点切り捨て
                                    let truncatedStamina = floor(stamina)
                                    Spacer()
                                    Image("Stamina")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .offset(x: 0, y: 0)
                                    VStack(alignment: .leading) {
                                        Text("スタミナ値: \(Int(truncatedStamina))")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 9))
                                        ProgressView(value: stamina / 100) // 0.0〜1.0に変換
                                            .scaleEffect(x: 1, y: 2) // 高さを増やす
                                        
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
                                        ProgressView(value: stress / 100) // 0.0〜1.0に変換
                                            .scaleEffect(x: 1, y: 2)
                                        
                                    }
                                    Spacer()
                                }
                                .frame(width: 230, height: 34)
                            }
                            
                            HStack {
                                Spacer()
                                Button("飯") {
                                    recoverStamina()
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
                                Button("遊") {
                                    if stamina > 0 {
                                        stamina -= 10
                                        stress = max(0, stress - 5) // 遊ぶとストレスが減る
                                    }
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
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
        .onAppear {
            startTimer()
            updateValuesFromBackground()
        }
        .onDisappear {
            saveLastActiveDate()
        }
    }
    // Timerを開始
    private func startTimer() {
        // 3分ごとにスタミナが減っていく処理
        staminatimer = Timer.scheduledTimer(withTimeInterval: 180, repeats: true) { _ in
            withAnimation {
                if stamina > 0 {
                    stamina -= 1
                }
            }
        }
    }
    // バックグラウンド復帰時にスタミナとストレスを更新
    private func updateValuesFromBackground() {
        let currentDate = Date()
        let elapsedTime = currentDate.timeIntervalSince(lastActiveDate) // 経過時間 (秒)
        
        // スタミナの減少: 3分ごとに1減少
        let staminaToReduce = Int(elapsedTime / 180)
        if staminaToReduce > 0 {
            stamina = max(0, stamina - Double(staminaToReduce)) // スタミナが0未満にならないように
        }
        
        // ストレスの増加: 5分ごとに1増加
        let stressToIncrease = Int(elapsedTime / 300)
        if stressToIncrease > 0 {
            stress = min(100, stress + Double(stressToIncrease)) // ストレスが100を超えないように
        }
        
        // タイムスタンプを現在時刻に更新
        lastActiveDate = currentDate
    }
    
    // アプリが閉じられる際にタイムスタンプを保存
    private func saveLastActiveDate() {
        lastActiveDate = Date()
    }
    // スタミナ回復処理
    private func recoverStamina() {
        stamina = min(100, stamina + 20) // スタミナを最大100まで回復
    }
}


#Preview {
    HomeView()
}
