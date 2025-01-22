




import SwiftUI

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
    @State private var localStaminaHours: Int = 0
    @State private var localStaminaMinutes: Int = 0
    @State private var localStaminaSeconds: Int = 0
    @State private var currentMonthUsage: (wifi: Double, wwan: Double) = (0, 0)
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    

    private let requiredPettingDuration: TimeInterval = 1.0  // 必要な撫で時間（秒）
    private let dragThreshold: CGFloat = 20.0  // ドラッグ判定の閾値
    
    // 初回起動時の処理を行うための初期化
    init() {
        let hasLaunched = UserDefaults.standard.bool(forKey: "hasLaunched")
        _showFirstLaunchOverlay = State(initialValue: !hasLaunched)
        // 保存された猫の名前を取得
        let savedName = UserDefaults.standard.string(forKey: "catName") ?? ""
        _catName = State(initialValue: savedName)
    }
    
    private func incrementNumber() {
        if dataNumber < 200 {
            dataNumber = min(200, dataNumber + 1)
        }
    }
    
    private func decrementNumber() {
        if dataNumber > 1 {
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
                                // 元の薄い背景に戻す
                                Rectangle()
                                    .fill(.white)
                                    .opacity(0.8)
                                    .frame(width: 85, height: 85)
                                    .cornerRadius(15)
                                
                                VStack(spacing: 4) {
                                    let (_, wwan) = currentMonthUsage
                                    
                                    Text("\(String(format: "%.1f", wwan))")
                                        .foregroundColor(Color.black.opacity(0.5))
                                        .font(.system(size: 22, weight: .medium))
                                    
                                    ZStack(alignment: .leading) {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 60, height: 4)
                                            .cornerRadius(2)
                                        
                                        let progress = dataNumber > 0 ?
                                            CGFloat(min(max(0, wwan) / Double(dataNumber), 1.0)) : 0
                                        
                                        Rectangle()
                                            .fill(.orange)
                                            .frame(width: 60 * progress, height: 4)
                                            .cornerRadius(2)
                                    }
                                    
                                    Text("\(dataNumber)GB")
                                        .foregroundColor(Color.black.opacity(0.5))
                                        .font(.system(size: 12))
                                    
                                    // ボタンであることを示す微妙な指示を追加
                                    Text("タップで詳細")
                                        .foregroundColor(Color.black.opacity(0.5))
                                        .font(.system(size: 9, weight: .medium))
                                        .padding(.top, 2)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        Spacer()
                        
                        VStack {
                            // Status Display
                            ZStack {
                                Rectangle()
                                    .fill(.white)
                                    .opacity(0.7)
                                    .cornerRadius(20)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                                    .frame(height: 34)
                                
                                HStack(spacing: 15) {
                                    // Stamina Section
                                    HStack(spacing: 6) {
                                        Image("Stamina")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 18, height: 18)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("残\(localStaminaHours):\(String(format: "%02d", localStaminaMinutes)):\(String(format: "%02d", localStaminaSeconds))")
                                                .foregroundColor(Color.black.opacity(0.5))
                                                .font(.system(size: 10, weight: .medium))
                                                .minimumScaleFactor(0.8)
                                            
                                            ProgressView(value: Double(giganekoPoint.stamina) / 100)
                                                .scaleEffect(x: 1, y: 1.5)
                                                .tint(.green)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 1, height: 25)
                                    
                                    // Stress Section
                                    HStack(spacing: 6) {
                                        Image("Stress")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 18, height: 18)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("\(Int(giganekoPoint.stress))%")
                                                .foregroundColor(Color.black.opacity(0.5))
                                                .font(.system(size: 12, weight: .medium))
                                                .minimumScaleFactor(0.8)
                                            
                                            ProgressView(value: Double(giganekoPoint.stress) / 100)
                                                .scaleEffect(x: 1, y: 1.5)
                                                .tint(.orange)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 15)
                            }
                            
                            HStack {
                                Spacer()
                                ZStack {
                                    Rectangle()
                                        .fill(.white)
                                        .opacity(0.7)
                                        .cornerRadius(15)
                                        .frame(width: 85, height: 28)
                                    
                                    HStack(spacing: 4) {
                                        Image("Point")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                        
                                        Text("\(giganekoPoint.currentPoints)")
                                            .foregroundColor(Color.black.opacity(0.5))
                                            .font(.system(size: 14, weight: .medium))
                                            .minimumScaleFactor(0.8)
                                        
                                        Text("pt")
                                            .foregroundColor(Color.black.opacity(0.5))
                                            .font(.system(size: 10))
                                    }
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
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
                                
                                // ポイント表示
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
                            .frame(height: UIScreen.main.bounds.height * 0.85)
                        HStack {
                            Spacer()
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
                                        Text("Lv \(giganekoPoint.like)")
                                            .foregroundColor(Color.black.opacity(0.5))
                                            .font(.system(size: 14))
                                        
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(width: 1, height: 15)
                                        
                                        HStack(spacing: 4) {
                                            Text(catName)
                                                .foregroundColor(Color.black.opacity(0.5))
                                                .font(.system(size: 14))
                                            Image(systemName: "pencil.circle.fill")
                                                .foregroundColor(.orange.opacity(0.8))
                                                .font(.system(size: 14))
                                        }
                                    }
                                    .frame(width: 160)
                                }
                            }
                            .frame(width: 150, height: 25)
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // 初回起動時のオーバーレイ
                if showFirstLaunchOverlay {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                            .frame(height: 100) // 上部の固定スペース
                            
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
                                    Text("名前を決めよう")
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
                                    // 猫の名前入力フィールド
                                    TextField("猫の名前を入力", text: $catName)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(.black)
                                        .frame(width: 200)
                                        .background(Color.white)
                                        .padding(.horizontal)
                                    
                                    // 次へボタン
                                    Button(action: {
                                        if !catName.isEmpty {
                                            withAnimation(.easeOut(duration: 0.3)) {
                                                showFirstLaunchOverlay = false
                                                showSecondLaunchOverlay = true
                                            }
                                        }
                                    }) {
                                        Text("次へ")
                                            .foregroundColor(.black)
                                            .frame(width: 200, height: 45)
                                            .background(Color(red: 232/255, green: 201/255, blue: 160/255))
                                            .cornerRadius(20)
                                    }
                                    .disabled(catName.isEmpty)
                                }
                                .padding(.bottom, 30)
                            }
                            .frame(width: 300)
                        }
                        
                        Spacer()
                    }
                    .ignoresSafeArea(.keyboard) // キーボードを無視
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
                                            UserDefaults.standard.set(catName, forKey: "catName")
                                            UserDefaults.standard.set(dataNumber, forKey: "dataNumber")
                                            UserDefaults.standard.set(true, forKey: "hasLaunched")
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
            currentMonthUsage = getCurrentMonthUsage()
            // 初期値を設定
            localStaminaHours = giganekoPoint.staminaHours
            localStaminaMinutes = giganekoPoint.staminaMinutes
            localStaminaSeconds = giganekoPoint.staminaSeconds
            // アプリ起動時にチュートリアル表示状態を確認
            let hasLaunched = UserDefaults.shared.bool(forKey: "hasLaunched")
            if !hasLaunched {
                tutorialViewModel.showTutorial = true
            }
            condition()
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

// チュートリアルの各ステップを定義
enum TutorialStep {
    case nameInput
    case dataInput
}

// 共通のオーバーレイコンポーネント
struct TutorialOverlay<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
        
        VStack {
            Spacer()
            
            ZStack {
                content
            }
            
            Spacer()
        }
        .transition(.scale.combined(with: .opacity))
    }
}

// 名前入力画面コンポーネント
struct NameInputView: View {
    @Binding var catName: String
    @Binding var showFirstLaunchOverlay: Bool
    @Binding var showSecondLaunchOverlay: Bool
    @Binding var isEditingName: Bool
    @State private var tempCatName: String = ""
    
    var body: some View {
        ZStack {
            Image("Tutorial1")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
            
            VStack(spacing: 20) {
                TutorialHeader(title: isEditingName ? "名前を変更" : "名前を決めよう")
                
                Spacer()
                    .frame(height: 70)
                
                VStack(spacing: 15) {
                    TextField("猫の名前を入力", text: $catName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(.black)
                        .frame(width: 200)
                        .background(Color.white)
                        .padding(.horizontal)
                    
                    HStack(spacing: 10) {
                        if isEditingName {
                            TutorialButton(
                                title: "キャンセル",
                                width: 95,
                                action: {
                                    catName = tempCatName
                                    showFirstLaunchOverlay = false
                                    isEditingName = false
                                }
                            )
                        }
                        
                        TutorialButton(
                            title: isEditingName ? "決定" : "次へ",
                            width: isEditingName ? 95 : 200,
                            action: {
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
                            },
                            isDisabled: catName.isEmpty
                        )
                    }
                }
                .padding(.bottom, 30)
            }
            .frame(width: 300)
        }
    }
}

// データ入力画面コンポーネント
struct DataInputView: View {
    @Binding var dataNumber: Int
    @Binding var showSecondLaunchOverlay: Bool
    @Binding var catName: String
    
    var body: some View {
        ZStack {
            Image("Tutorial2")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
                TutorialHeader(title: "通信量を決めよう")
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 40)
                    
                    DataNumberSelector(dataNumber: $dataNumber)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    TutorialButton(
                        title: "設定",
                        width: 200,
                        action: {
                            if dataNumber > 0 && dataNumber <= 200 {
                                UserDefaults.shared.set(catName, forKey: "catName")
                                UserDefaults.shared.set(dataNumber, forKey: "dataNumber")
                                UserDefaults.shared.set(true, forKey: "hasLaunched")
                                withAnimation(.easeOut(duration: 0.3)) {
                                    showSecondLaunchOverlay = false
                                }
                            }
                        },
                        isDisabled: dataNumber <= 0 || dataNumber > 200
                    )
                }
                .padding(.bottom, 30)
            }
            .frame(width: 300)
        }
    }
}

// 共通のヘッダーコンポーネント
struct TutorialHeader: View {
    let title: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.title)
                .bold()
                .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))
                .padding(.top, -30)
        }
        .padding()
    }
}

// 共通のボタンコンポーネント
struct TutorialButton: View {
    let title: String
    let width: CGFloat
    let action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.black)
                .frame(width: width, height: 45)
                .background(Color(red: 232/255, green: 201/255, blue: 160/255))
                .cornerRadius(20)
        }
        .disabled(isDisabled)
    }
}

// データ数値セレクターコンポーネント
struct DataNumberSelector: View {
    @Binding var dataNumber: Int
    
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
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: decrementNumber) {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(red: 232/255, green: 201/255, blue: 160/255))
            }
            .padding(.leading, 20)
            
            Text("\(dataNumber)")
                .font(.system(size: 70, weight: .bold))
                .frame(minWidth: 150)
                .multilineTextAlignment(.center)
            
            Button(action: incrementNumber) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(Color(red: 232/255, green: 201/255, blue: 160/255))
            }
            .padding(.trailing, 20)
        }
        .frame(width: 200, height: 80)
    }
}
