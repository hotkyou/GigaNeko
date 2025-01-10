import SwiftUI

// チュートリアルコンテンツの構造体
struct TutorialContent {
    let title: String
    let imageName: String
    let mainText: String
    let subText: String
}

// TutorialViewModel の実装
class TutorialViewModel: ObservableObject {
    @Published var currentScreen: Int = 0
    @Published var showTutorial: Bool
    
    init() {
        // 初回起動判定に基づいてshowTutorialを初期化
        let hasLaunched = UserDefaults.shared.bool(forKey: "hasLaunched")
        self.showTutorial = !hasLaunched
    }
    
    let tutorials: [TutorialContent] = [
        TutorialContent(
            title: "ようこそ！",
            imageName: "Neko",
            mainText: "インストールありがとうございます！",
            subText: "このアプリの説明を始めていくよ"
        ),
        TutorialContent(
            title: "猫のお世話",
            imageName: "NekoCare",
            mainText: "猫との暮らし方",
            subText: "スタミナとストレス値に注意して\n毎日お世話をしてあげましょう"
        ),
        TutorialContent(
            title: "データ管理",
            imageName: "NekoData",
            mainText: "通信量を確認",
            subText: "毎日の通信量を可視化して\n確認することができます"
        ),
        TutorialContent(
            title: "ポイント",
            imageName: "NekoPoint",
            mainText: "ポイントを貯めよう",
            subText: "データ通信を節約すると\nポイントが貯まります"
        ),
        TutorialContent(
            title: "準備完了！",
            imageName: "NekoReady",
            mainText: "さあ、始めましょう！",
            subText: "猫と一緒に楽しく\n通信量を管理していきましょう"
        )
    ]
    
    var isLastScreen: Bool {
        currentScreen == tutorials.count - 1
    }
    
    var isFirstScreen: Bool {
        currentScreen == 0
    }
    
    func nextScreen() {
        if currentScreen < tutorials.count - 1 {
            currentScreen += 1
        }
    }
    
    func previousScreen() {
        if currentScreen > 0 {
            currentScreen -= 1
        }
    }
    
    func resetTutorial() {
        currentScreen = 0
        showTutorial = false
    }
}

// ページインジケーターコンポーネント
struct TutorialPageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.gray : Color.gray.opacity(0.3))
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: currentPage)
            }
        }
    }
}

// メインのチュートリアル画面コンポーネント
struct TutorialScreenView_Extended: View {
    let content: TutorialContent
    let buttonTitle: String
    let buttonAction: () -> Void
    let isFirstScreen: Bool
    let onBack: () -> Void
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        ZStack {
            // 背景のオーバーレイ
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // グラデーション背景
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.purple.opacity(0.6)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // メインコンテンツ
            contentCard
        }
        .transition(.opacity.combined(with: .scale))
    }
    
    private var contentCard: some View {
        VStack(spacing: 20) {
            // ヘッダータイトルとページ番号
            HStack {
                Text(content.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Spacer()
                
                Text("\(currentPage + 1)/\(totalPages)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.2))
                    )
            }
            
            // メインカード
            cardContent
                .frame(width: 300, height: 280)
            
            // ページインジケーター
            TutorialPageIndicator(currentPage: currentPage, totalPages: totalPages)
                .padding(.top, 5)
            
            // ボタングループ
            buttonGroup
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(red: 232/255, green: 201/255, blue: 160/255))
                .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
        )
        .padding(.horizontal, 20)
    }
    
    private var cardContent: some View {
        ZStack {
            // カード背景
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 255/255, green: 242/255, blue: 209/255))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // カードコンテンツ
            VStack(spacing: 15) {
                Image(content.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180)
                    .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 3)
                
                Text(content.mainText)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                
                Text(content.subText)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .lineSpacing(4)
            }
            .padding(.vertical)
        }
    }
    
    private var buttonGroup: some View {
        HStack(spacing: 15) {
            // 戻るボタン（最初の画面以外で表示）
            if !isFirstScreen {
                TutorialButton(
                    title: "戻る",
                    width: 100,
                    action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            onBack()
                        }
                    }
                )
                .transition(.slide)
            }
            
            // 次へ/始めるボタン
            TutorialButton(
                title: buttonTitle,
                width: isFirstScreen ? 220 : 100,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        buttonAction()
                    }
                }
            )
        }
        .padding(.top, 5)
        .padding(.bottom, 10)
    }
}
