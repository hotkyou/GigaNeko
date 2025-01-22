import SwiftUI

struct HomeView: View {
    @StateObject private var tutorialViewModel = TutorialViewModel()
    @StateObject private var particleSystem = ParticleSystem()
    @State private var offsetY: CGFloat = 0
    @State private var movingDown = true
    @State private var showWelcomeScreen = false
    @State private var showFirstLaunchOverlay = false
    @State private var showSecondLaunchOverlay = false
    @State private var catName = ""
    @State private var dataNumber: Int = 0
    @State private var pettingStartTime: Date?
    @State private var lastDragLocation: CGPoint?
    @State private var isDragging = false
    @State private var pettingTimer: Timer?
    @State private var isEditingName = false
    @State private var tempCatName = ""
    @State private var localStaminaHours: Int = 0
    @State private var localStaminaMinutes: Int = 0
    @State private var localStaminaSeconds: Int = 0
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    private let staminaTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let requiredPettingDuration: TimeInterval = 1.0  // 必要な撫で時間（秒）
    private let dragThreshold: CGFloat = 20.0  // ドラッグ判定の閾値
    let giganekoPoint = GiganekoPoint.shared
    
    // 初回起動時の処理を行うための初期化
    init() {
        // UserDefaultsから初回起動フラグを取得
        let hasLaunched = UserDefaults.shared.bool(forKey: "hasLaunched")
        let hasCatName = UserDefaults.shared.string(forKey: "catName") != nil
        
        // StateObjectの初期化
        _tutorialViewModel = StateObject(wrappedValue: TutorialViewModel())
        
        // 初回起動時の処理
        if !hasLaunched {
            // チュートリアルを表示するように設定
            tutorialViewModel.showTutorial = true
            _showFirstLaunchOverlay = State(initialValue: false)
        } else {
            // 猫の名前が設定されていない場合は名前入力画面を表示
            _showFirstLaunchOverlay = State(initialValue: !hasCatName)
        }
        
        // その他の初期化
        let savedName = UserDefaults.shared.string(forKey: "catName") ?? ""
        _catName = State(initialValue: savedName)
        let savedDataNumber = UserDefaults.shared.integer(forKey: "dataNumber")
        _dataNumber = State(initialValue: savedDataNumber)
    }
    
    private func condition(){
        giganekoPoint.checkDate()
    }
    
    private func caress(){
        giganekoPoint.caressLike()
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
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ success, error in
            if success {
                print("通知の許可が得られました")
                scheduleNotification()
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // 2. 通知をスケジュール
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "目標ギガ数に達しました"
        content.body = "猫がブチギレています"
        content.sound = .default
        
        // 10秒後に通知
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // 通知の登録状態を確認
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知の登録に失敗: \(error)")
            } else {
                print("通知の登録に成功")
            }
        }
        
        // 登録された通知を確認
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("保留中の通知: \(requests.count)件")
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("通知の権限状態: \(settings.authorizationStatus.rawValue)")
            print("通知バナーの設定: \(settings.alertSetting.rawValue)")
            print("通知音の設定: \(settings.soundSetting.rawValue)")
        }
    }
    

    // スタミナとストレス値
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
                        // Left Section - Giga Display
                        NavigationLink(destination: StatisticsView()) {
                            ZStack {
                                Rectangle()
                                    .fill(.white)
                                    .opacity(0.8)
                                    .frame(width: 85, height: 85)
                                    .cornerRadius(15)
                                
                                VStack(spacing: 4) {
                                    let (_, wwan) = getCurrentMonthUsage()
                                    
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
                                    .opacity(0.8)
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
                            
                            Spacer()
                                .frame(height: 20)
                            
                            // Points Display
                            HStack {
                                Spacer()
                                ZStack {
                                    Rectangle()
                                        .fill(.white)
                                        .opacity(0.8)
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
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 30)
                    .padding(.top, 50)
                    
                    // 中央のキャラクター表示
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            // パーティクル表示用のレイヤー
                            GeometryReader { geometry in
                                let frame = geometry.frame(in: .global)
                                Image(isDragging ? "NadeNeko" : "Neko")
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
                                                                particleSystem.createRisingHearts(in: frame)
                                                                //好感度付与
                                                                caress()
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
                    HStack{
                        Spacer()
                        VStack {
                            Spacer()
                                .frame(height: UIScreen.main.bounds.height * 0.75)
                            
                            // レベルと名前表示のZStack
                            ZStack {
                                Rectangle()
                                    .fill(Color.white)
                                    .opacity(0.8)
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
                            .frame(width: 180)
                            
                            Spacer()
                        }
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.all)
                
                // チュートリアル画面
                if tutorialViewModel.showTutorial {
                    let content = tutorialViewModel.tutorials[tutorialViewModel.currentScreen]
                    TutorialScreenView_Extended(
                        content: content,
                        buttonTitle: tutorialViewModel.isLastScreen ? "始める" : "次へ",
                        buttonAction: {
                            if tutorialViewModel.isLastScreen {
                                // チュートリアル完了時の処理
                                tutorialViewModel.showTutorial = false
                                showFirstLaunchOverlay = true
                            } else {
                                tutorialViewModel.nextScreen()
                            }
                        },
                        isFirstScreen: tutorialViewModel.isFirstScreen,
                        onBack: {
                            tutorialViewModel.previousScreen()
                        },
                        currentPage: tutorialViewModel.currentScreen,
                        totalPages: tutorialViewModel.tutorials.count
                    )
                    .transition(.opacity)
                    .zIndex(2) // チュートリアルを最前面に表示
                }
                
                // 名前入力オーバーレイ
                if showFirstLaunchOverlay {
                    TutorialOverlay {
                        NameInputView(
                            catName: $catName,
                            showFirstLaunchOverlay: $showFirstLaunchOverlay,
                            showSecondLaunchOverlay: $showSecondLaunchOverlay,
                            isEditingName: $isEditingName
                        )
                    }
                    .ignoresSafeArea(.keyboard)
                } else if showSecondLaunchOverlay {
                    TutorialOverlay {
                        DataInputView(
                            dataNumber: $dataNumber,
                            showSecondLaunchOverlay: $showSecondLaunchOverlay,
                            catName: $catName
                        )
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        } // NavigationView
        .onReceive(staminaTimer) { _ in
            updateLocalStaminaTime()
        }
        .onAppear {
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
            // 通知のリクエスト
            requestNotificationPermission()
        }
        .onDisappear {
            condition()
        }
        .scrollDisabled(true)
    }
    
    // ローカルタイマー更新処理を追加
    private func updateLocalStaminaTime() {
        if localStaminaSeconds > 0 {
            localStaminaSeconds -= 1
        } else {
            if localStaminaMinutes > 0 {
                localStaminaMinutes -= 1
                localStaminaSeconds = 59
            } else {
                if localStaminaHours > 0 {
                    localStaminaHours -= 1
                    localStaminaMinutes = 59
                    localStaminaSeconds = 59
                }
            }
        }
        
        // スタミナが0になった場合の処理
        if localStaminaHours == 0 && localStaminaMinutes == 0 && localStaminaSeconds == 0 {
            // 必要に応じてここに追加の処理
            giganekoPoint.stamina = 0
        }
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
