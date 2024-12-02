import SwiftUI

// パーティクル1つの情報を保持する構造体
struct HeartParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var rotation: Double
    var offset: CGSize
}

class ParticleSystem: ObservableObject {
    @Published var particles: [HeartParticle] = []
    private var lastParticleTime: Date = Date()
    private let particleInterval: TimeInterval = 1.0  // パーティクル生成間隔
    
    func createRisingHearts(in frame: CGRect) {
        let now = Date()
        if now.timeIntervalSince(lastParticleTime) >= particleInterval {
            let baseX = frame.midX
            let baseY = frame.midY - 50
            
            // 3つのハートを生成（左、中央、右）
            let positions = [
                CGPoint(x: baseX - 25, y: baseY),
                CGPoint(x: baseX, y: baseY - 10),
                CGPoint(x: baseX + 25, y: baseY)
            ]
            
            for position in positions {
                let particle = HeartParticle(
                    position: position,
                    scale: CGFloat.random(in: 1.5...2.0),  // 大きめのサイズ
                    opacity: 1,
                    rotation: 0,  // 回転なし
                    offset: .zero
                )
                particles.append(particle)
            }
            
            lastParticleTime = now
            
            // シンプルな上昇アニメーション
            withAnimation(.easeOut(duration: 5.0)) {  // アニメーション時間2秒
                for i in particles.indices.suffix(3) {
                    particles[i].offset = CGSize(
                        width: 0,        // 横移動なし
                        height: -400     // まっすぐ上に移動
                    )
                    particles[i].opacity = 0  // フェードアウト
                }
            }
            
            // アニメーション後にパーティクルを削除
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.particles.removeAll { particle in
                    particle.opacity == 0
                }
            }
        }
    }
}

struct HomeView: View {
    @State private var offsetY: CGFloat = 0
    @State private var movingDown = true
    @State private var showFirstLaunchOverlay = false
    @State private var showSecondLaunchOverlay = false
    @State private var catName = ""
    @State private var dataNumber: Int = 0
    @StateObject private var particleSystem = ParticleSystem()
    @State private var pettingStartTime: Date?
    @State private var lastDragLocation: CGPoint?
    @State private var isDragging = false
    @State private var pettingTimer: Timer?
    @State private var isEditingName = false
    @State private var tempCatName = ""
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    

    private let requiredPettingDuration: TimeInterval = 1.0  // 必要な撫で時間（秒）
    private let dragThreshold: CGFloat = 20.0  // ドラッグ判定の閾値
    
    // 初回起動時の処理を行うための初期化
    init() {
        let hasLaunched = UserDefaults.shared.bool(forKey: "hasLaunched")
        _showFirstLaunchOverlay = State(initialValue: !hasLaunched)
        // 保存された猫の名前を取得
        let savedName = UserDefaults.shared.string(forKey: "catName") ?? ""
        _catName = State(initialValue: savedName)
        // 保存されたデータ上限値を取得
        let savedDataNumber = UserDefaults.shared.integer(forKey: "dataNumber")
        _dataNumber = State(initialValue: savedDataNumber)
    }
    
    private func incrementNumber() {
        if dataNumber < 200 {
            dataNumber = min(200, dataNumber + 1)
        }
    }
    
    private func decrementNumber() {
        if dataNumber > 0 {
            dataNumber = max(1, dataNumber - 1)
        }
    }

    // スタミナとストレス値
    @State private var stamina: Double = 80
    @State private var stress: Double = 15
    @State private var staminatimer: Timer?
    @AppStorage("lastActiveDate") private var lastActiveDate: Date = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // メインコンテンツ
                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Image("HomeBackGroundImage")
                            .resizable()
                            .scaledToFit()
                            .frame(height: geometry.size.height)
                            .offset(x: 0, y: 0)
                    }
                    
                    // 上部のステータス表示
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
                                
                                let (_, wwan) = getCurrentMonthUsage()
                                VStack(spacing: 6) {
                                    Text("\(String(format: "%.1f", wwan))")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 26, weight: .medium))
                                    
                                    ZStack(alignment: .leading) {
                                        // バーの背景
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 5)
                                            .cornerRadius(2.5)
                                        
                                        // 使用量のバー
                                        Rectangle()
                                            .fill(Color.orange)
                                            .frame(width: 60 * CGFloat(min(wwan / Double(dataNumber), 1.0)), height: 5)
                                            .cornerRadius(2.5)
                                    }
                                    
                                    Text("\(dataNumber)GB")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                }
                            }
                            .padding(.leading, leftPadding)
                            .padding(.top, 65)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                // ステータス表示ZStack
                                ZStack {
                                    Rectangle()
                                        .fill(Color.white)
                                        .frame(width: 230, height: 34)
                                        .opacity(0.7)
                                        .cornerRadius(20)
                                    
                                    HStack(spacing: 15) {
                                        let truncatedStamina = floor(stamina)
                                        // スタミナ表示
                                        HStack(spacing: 8) {
                                            Image("Stamina")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("\(Int(truncatedStamina))%")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12, weight: .medium))
                                                ProgressView(value: stamina / 100)
                                                    .scaleEffect(x: 1, y: 1.5)
                                                    .tint(.green)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)

                                        // 区切り線
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 1, height: 25)
                                        
                                        // ストレス表示
                                        HStack(spacing: 8) {
                                            Image("Stress")
                                                .resizable()
                                                .frame(width: 18, height: 18)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("\(Int(stress))%")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12, weight: .medium))
                                                ProgressView(value: stress / 100)
                                                    .scaleEffect(x: 1, y: 1.5)
                                                    .tint(.orange)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .padding(.horizontal, 15)
                                }
                                
                                // ボタンとポイント表示
                                HStack {
                                    // 飯ボタン
                                    Button(action: recoverStamina) {
                                        HStack(spacing: 4) {
                                            Image(systemName: "fork.knife")
                                                .font(.system(size: 12))
                                            Text("飯")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.green)
                                        .cornerRadius(15)
                                    }
                                    
                                    // 遊ぶボタン
                                    Button {
                                        if stamina > 0 {
                                            stamina -= 10
                                            stress = max(0, stress - 5)
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Image(systemName: "party.popper")
                                                .font(.system(size: 12))
                                            Text("遊")
                                                .font(.system(size: 14, weight: .medium))
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue)
                                        .cornerRadius(15)
                                    }
                                    
                                    // ポイント表示
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(width: 85, height: 28)
                                            .opacity(0.7)
                                            .cornerRadius(15)
                                        
                                        HStack(spacing: 4) {
                                            Image("Point")
                                                .resizable()
                                                .frame(width: 16, height: 16)
                                            Text("3,000")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14, weight: .medium))
                                            Text("pt")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 10))
                                        }
                                    }
                                }
                                .frame(width: 230)
                            }
                        }
                        .padding(.trailing, leftPadding)
                        .padding(.top, 65)
                    }
                    
                    // 中央のキャラクター表示
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            GeometryReader { geometry in
                                Image("Neko")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 300)
                                    .offset(y: offsetY)
                                    .gesture(
                                        DragGesture(minimumDistance: 0)
                                            .onChanged { value in
                                                let currentLocation = value.location
                                                
                                                if let lastLocation = lastDragLocation {
                                                    let distance = sqrt(
                                                        pow(currentLocation.x - lastLocation.x, 2) +
                                                        pow(currentLocation.y - lastLocation.y, 2)
                                                    )
                                                    
                                                    if distance >= dragThreshold {
                                                        if !isDragging {
                                                            isDragging = true
                                                            pettingStartTime = Date()
                                                            
                                                            // 撫で始めたらタイマーを開始
                                                            pettingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                                                                particleSystem.createRisingHearts(
                                                                    in: geometry.frame(in: .global)
                                                                )
                                                            }
                                                        }
                                                        lastDragLocation = currentLocation
                                                    }
                                                } else {
                                                    lastDragLocation = currentLocation
                                                }
                                            }
                                            .onEnded { _ in
                                                isDragging = false
                                                pettingStartTime = nil
                                                lastDragLocation = nil
                                                pettingTimer?.invalidate()
                                                pettingTimer = nil
                                            }
                                    )
                            }
                            .frame(width: 300, height: 300)
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
                    
                    // パーティクル表示用のレイヤー
                    ZStack {
                        ForEach(particleSystem.particles) { particle in
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink.opacity(0.8))
                                .scaleEffect(particle.scale)
                                .opacity(particle.opacity)
                                .rotationEffect(.degrees(particle.rotation))
                                .position(particle.position)
                                .offset(particle.offset)
                        }
                    }
                    
                    // 下部のレベル表示
                    VStack {
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height * 0.75)
                        
                        // レベルと名前表示のZStack
                        ZStack {
                            Rectangle()
                                .fill(Color.white)
                                .opacity(0.7)
                                .cornerRadius(20)
                                .frame(height: 30)
                            
                            Button(action: {
                                // 名前変更用のオーバーレイを表示
                                tempCatName = catName  // 現在の名前を一時保存
                                showFirstLaunchOverlay = true
                                isEditingName = true
                            }) {
                                HStack(spacing: 12) {
                                    Text("Lv100")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 14))
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 1, height: 15)

                                    HStack(spacing: 4) {
                                        Text(catName)
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.orange.opacity(0.8))
                                            .font(.system(size: 14))
                                    }
                                }
                                .frame(width: 160)
                            }
                        }
                        .frame(width: 180)
                        
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // 名前入力オーバーレイ
                if showFirstLaunchOverlay {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                            .frame(height: 100)
                            
                        ZStack {
                            // チュートリアル画像
                            Image("Tutorial1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                            
                            // テキストと入力フィールド、ボタンを含むVStack
                            VStack(spacing: 20) {
                                // 上部の説明テキスト
                                VStack(spacing: 10) {
                                    Text(isEditingName ? "名前を変更" : "名前を決めよう")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))
                                        .padding(.top, -30)
                                }
                                .padding()
                                
                                Spacer()
                                    .frame(height: 70)
                                
                                // 入力フィールドとボタンを縦に並べるVStack
                                VStack(spacing: 15) {
                                    TextField("猫の名前を入力", text: $catName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(.black)
                                        .frame(width: 200)
                                        .background(Color.white)
                                        .padding(.horizontal)
                                    
                                    HStack(spacing: 10) {
                                        if isEditingName {
                                            // キャンセルボタン
                                            Button(action: {
                                                catName = tempCatName  // 元の名前に戻す
                                                showFirstLaunchOverlay = false
                                                isEditingName = false
                                            }) {
                                                Text("キャンセル")
                                                    .foregroundColor(.black)
                                                    .frame(width: 95, height: 45)
                                                    .background(Color(red: 232/255, green: 201/255, blue: 160/255))
                                                    .cornerRadius(20)
                                            }
                                        }
                                        
                                        // 次へ/決定ボタン
                                        Button(action: {
                                            if !catName.isEmpty {
                                                UserDefaults.shared.set(catName, forKey: "catName")
                                                if isEditingName {
                                                    showFirstLaunchOverlay = false
                                                    isEditingName = false
                                                } else {
                                                    showSecondLaunchOverlay = true
                                                    showFirstLaunchOverlay = false
                                                }
                                            }
                                        }) {
                                            Text(isEditingName ? "決定" : "次へ")
                                                .foregroundColor(.black)
                                                .frame(width: isEditingName ? 95 : 200, height: 45)
                                                .background(Color(red: 232/255, green: 201/255, blue: 160/255))
                                                .cornerRadius(20)
                                        }
                                        .disabled(catName.isEmpty)
                                    }
                                }
                                .padding(.bottom, 30)
                            }
                            .frame(width: 300)
                        }
                        
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard)
                    .transition(.scale.combined(with: .opacity))
                } else if showSecondLaunchOverlay {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                            .frame(height: 100) // 上部の固定スペース
                            
                        ZStack {
                            // チュートリアル画像
                            Image("Tutorial2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300)
                            
                            // テキストと入力フィールド、ボタンを含むVStack
                            VStack(spacing: 20) {
                                // 上部の説明テキスト
                                VStack(spacing: 10) {
                                    Text("通信量を決めよう")
                                        .font(.title)
                                        .bold()
                                        .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))
                                }
                                .padding()
                                
                                // 入力フィールドとボタンを縦に並べるVStack
                                VStack(spacing: 0) {
                                    // 選択された数値の大きな表示
                                    HStack(spacing: 0) {
                                        // マイナスボタン
                                        Button(action: decrementNumber) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(red: 232/255, green: 201/255, blue: 160/255))
                                        }
                                        .padding(.leading, 20)
                                        
                                        Spacer()
                                            .frame(minWidth: 10)
                                        
                                        // 現在の値の表示
                                        Text("\(dataNumber)")
                                            .font(.system(size: 70, weight: .bold))
                                            .frame(minWidth: 150)
                                            .multilineTextAlignment(.center)
                                        
                                        Spacer()
                                            .frame(minWidth: 10)
                                        
                                        // プラスボタン
                                        Button(action: incrementNumber) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(Color(red: 232/255, green: 201/255, blue: 160/255))
                                        }
                                        .padding(.trailing, 20)
                                    }
                                    .frame(width: 200, height: 80)
                                    
                                    Spacer()
                                        .frame(height: 60)
                                    
                                    // 設定ボタン
                                    Button(action: {
                                        if dataNumber > 0 && dataNumber <= 200 {
                                            UserDefaults.shared.set(catName, forKey: "catName")
                                            UserDefaults.shared.set(dataNumber, forKey: "dataNumber")
                                            UserDefaults.shared.set(true, forKey: "hasLaunched")
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                showSecondLaunchOverlay = false
                                            }
                                        }
                                    }) {
                                        Text("設定")
                                            .foregroundColor(.black)
                                            .frame(width: 200, height: 45)
                                            .background(Color(red: 232/255, green: 201/255, blue: 160/255))
                                            .cornerRadius(20)
                                    }
                                    .disabled(dataNumber <= 0 || dataNumber > 200)
                                }
                                .padding(.bottom, 30)
                            }
                            .frame(width: 300)
                        }
                        
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
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
        .scrollDisabled(true)
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
