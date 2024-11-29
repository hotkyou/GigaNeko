import Foundation

extension UserDefaults {
    // シングルトンインスタンス
    static let shared: UserDefaults = {
        // App Groupのidentifierを設定
        let groupIdentifier = "group.hotkyou.giganeko"
        // App Group用のUserDefaultsを取得、失敗した場合は標準のUserDefaultsを使用
        return UserDefaults(suiteName: groupIdentifier) ?? .standard
    }()
}
