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
    let timer = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
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
                                        let progress: CGFloat = if dataNumber > 0 {
                                            CGFloat(min(max(0, wwan) / Double(dataNumber), 1.0))
                                        } else {
                                            0
                                        }

                                        Rectangle()
                                            .fill(Color.orange)
                                            .frame(width: 60 * progress, height: 5)
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
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7)
                                        .frame(height: 34)
                                        .opacity(0.7)
                                        .cornerRadius(20)
                                    
                                    HStack(spacing: 15) {
                                        let truncatedStamina = floor(giganekoPoint.stamina)
                                        // スタミナ表示
                                        HStack(spacing: 8) {
                                            Image("Stamina")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit) // アスペクト比を維持
                                                .frame(width: 18, height: 18)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("\(Int(giganekoPoint.stamina))%")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .minimumScaleFactor(0.8) // テキストが収まらない場合は縮小
                                                ProgressView(value: giganekoPoint.stamina / 100)
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
                                                .aspectRatio(contentMode: .fit) // アスペクト比を維持
                                                .frame(width: 18, height: 18)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("\(Int(giganekoPoint.stress))%")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 12, weight: .medium))
                                                    .minimumScaleFactor(0.8) // テキストが収まらない場合は縮小
                                                ProgressView(value: Double(giganekoPoint.stress) / 100)
                                                    .scaleEffect(x: 1, y: 1.5)
                                                    .tint(.orange)
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .padding(.horizontal, 15)
                                }
                                
                                // ボタンとポイント表示
                                HStack(spacing: 8) { // スペーシングを調整
                                    Spacer()
                                    // ポイント表示
                                    ZStack {
                                        Rectangle()
                                            .fill(Color.white)
                                            .frame(maxWidth: 85) // 最大幅を設定
                                            .frame(height: 28)
                                            .opacity(0.7)
                                            .cornerRadius(15)
                                        
                                        
                                        HStack(spacing: 4) {
                                            Image("Point")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit) // アスペクト比を維持
                                                .frame(width: 16, height: 16)
                                            Text("\(giganekoPoint.currentPoints)")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 14, weight: .medium))
                                                .minimumScaleFactor(0.8) // テキストが収まらない場合は縮小
                                            Text("pt")
                                                .foregroundColor(.gray)
                                                .font(.system(size: 10))
                                        }
                                    }
                                }
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.7) // 画面幅に応じて最大幅を設定
                            }
                        }
                        .padding(.trailing, min(leftPadding, UIScreen.main.bounds.width * 0.1)) // 右パディングを画面サイズに応じて制限
                        .padding(.top, 65)
                    }
                    
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
        .onAppear {
            // アプリ起動時にチュートリアル表示状態を確認
            let hasLaunched = UserDefaults.shared.bool(forKey: "hasLaunched")
            if !hasLaunched {
                tutorialViewModel.showTutorial = true
            }
            condition()
        }
        .onDisappear {
            condition()
        }
        .scrollDisabled(true)
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
            
            VStack(spacing: 20) {
                TutorialHeader(title: "通信量を決めよう")
                
                VStack(spacing: 0) {
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
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 232/255, green: 201/255, blue: 160/255))
            }
            .padding(.leading, 20)
            
            Spacer()
                .frame(minWidth: 10)
            
            Text("\(dataNumber)")
                .font(.system(size: 70, weight: .bold))
                .frame(minWidth: 150)
                .multilineTextAlignment(.center)
            
            Spacer()
                .frame(minWidth: 10)
            
            Button(action: incrementNumber) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(red: 232/255, green: 201/255, blue: 160/255))
            }
            .padding(.trailing, 20)
        }
        .frame(width: 200, height: 80)
    }
}
