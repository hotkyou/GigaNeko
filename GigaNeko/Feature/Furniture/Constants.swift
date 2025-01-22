import SwiftUI

enum Constants {
    // モダンなグラデーションカラー
    static let mainGradient = [
        Color(red: 134/255, green: 239/255, blue: 172/255).opacity(0.7),  // ライトミントグリーン
        Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.7)    // ライトブルー
    ]
    
    enum Colors {
        static let primary = Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.8)
        static let secondary = Color(red: 134/255, green: 239/255, blue: 172/255).opacity(0.8)
        static let accent = Color(red: 249/255, green: 115/255, blue: 22/255).opacity(0.8)
        static let background = Color(red: 249/255, green: 250/255, blue: 251/255)
        static let text = Color(red: 17/255, green: 24/255, blue: 39/255).opacity(0.9)
    }
    
    // よりソフトなシャドウ
    enum Shadows {
        static let small = Color.black.opacity(0.03)
        static let medium = Color.black.opacity(0.07)
        static let large = Color.black.opacity(0.12)
    }
    
    // アニメーション設定
    enum Animation {
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.2)
        static let easeInOut = SwiftUI.Animation.easeInOut(duration: 0.3)
    }
    
    // レイアウト定数
    enum Layout {
        static let cornerRadius: CGFloat = 24
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 20
    }
}
