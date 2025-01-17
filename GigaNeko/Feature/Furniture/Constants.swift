import SwiftUI

enum Constants {
    // モダンなグラデーションカラー
    static let mainGradient = [
        Color(red: 134/255, green: 239/255, blue: 172/255).opacity(0.9),  // ミントグリーン
        Color(red: 59/255, green: 130/255, blue: 246/255).opacity(0.9)    // ブライトブルー
    ]
    
    enum Colors {
        static let primary = Color(red: 59/255, green: 130/255, blue: 246/255)
        static let secondary = Color(red: 134/255, green: 239/255, blue: 172/255)
        static let accent = Color(red: 249/255, green: 115/255, blue: 22/255)
        static let background = Color(red: 249/255, green: 250/255, blue: 251/255)
        static let text = Color(red: 17/255, green: 24/255, blue: 39/255)
    }
    
    // シャドウ
    enum Shadows {
        static let small = Color.black.opacity(0.05)
        static let medium = Color.black.opacity(0.1)
        static let large = Color.black.opacity(0.15)
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
