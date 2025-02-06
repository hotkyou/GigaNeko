//
//  PrivacyPolicyView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/11/18.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("プライバシーポリシー")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom)
                
                // 1. 収集する情報
                PolicySection(title: "1. 収集する情報") {
                    SubSection(title: "1.1 ユーザーが提供する情報") {
                        BulletPoint("アカウント情報", detail: "必要に応じて、ユーザー名やメールアドレスなど、アカウント作成時に提供される情報。")
                        BulletPoint("お問い合わせ内容", detail: "サポートを受ける際に提供される情報。")
                    }
                    
                    SubSection(title: "1.2 デバイスから自動的に収集される情報") {
                        BulletPoint("デバイス情報", detail: "iOSデバイスのモデル、OSバージョン、アプリのクラッシュログなど。")
                        BulletPoint("アプリの利用データ", detail: "本アプリの利用状況や機能の利用頻度。")
                        BulletPoint("通信データの使用量", detail: "ポイント換算のために必要な範囲での通信量データ。")
                    }
                    
                    SubSection(title: "1.3 サードパーティサービスからの情報") {
                        BulletPoint("認証情報", detail: "Apple ID、Game Centerなどの認証を通じて提供される情報（Appleのガイドラインに基づき取得）。")
                    }
                }
                
                // 2. 情報の利用目的
                PolicySection(title: "2. 情報の利用目的") {
                    Text("本アプリでは、収集した情報を以下の目的で使用します：")
                    NumberedList(items: [
                        "アプリの基本機能（通信データのポイント換算やゲーム進行）の提供。",
                        "アプリの安定性とパフォーマンスの改善。",
                        "不正利用の検出および防止。",
                        "ユーザーサポートの提供。",
                        "広告表示やマーケティング活動（必要な場合は事前に同意を取得）。"
                    ])
                }
                
                // 残りのセクション
                PolicySection(title: "3. 情報の共有") {
                    Text("本アプリは、以下の場合を除き、ユーザー情報を第三者と共有しません：")
                    NumberedList(items: [
                        "ユーザーが同意した場合。",
                        "サービス提供に必要な業務を第三者に委託する場合（例：分析ツールやクラウドサービスの利用）。",
                        "法律に基づき情報の開示が必要な場合。"
                    ])
                    
                    Text("本アプリでは、以下のサードパーティサービスを利用する場合があります：")
                    BulletPoint("Appleサービス", detail: "Sign in with Apple、Game Center。")
                    BulletPoint("分析ツール", detail: "Firebase Analytics、App Store Connect Analytics（匿名データのみ使用）。")
                }
                
                PolicySection(title: "4. 情報の保存期間") {
                    Text("ユーザー情報は、利用目的に必要な期間のみ保存します。保存期間が終了した情報は、安全かつ適切に削除します。")
                }
                // 残りのセクション
                PolicySection(title: "5. ユーザーの権利") {
                    Text("ユーザーは、以下の権利を有します")
                    NumberedList(items: [
                        "自身の情報へのアクセス、修正、削除の要求",
                        "データ収集のオプトアウト（例：分析データの共有停止）。",
                        "アプリ設定からプライバシー設定の確認および変更が可能です。"
                    ])
                    
                }
                // 残りのセクション
                PolicySection(title: "6. セキュリティ対策") {
                    Text("本アプリは、ユーザー情報を安全に管理するため、以下のセキュリティ対策を講じます")
                    NumberedList(items: [
                        "Appleの推奨するセキュリティ標準に従ったデータ暗号化。",
                        "個人情報へのアクセスを制限",
                        "アプリの定期的なセキュリティチェック"
                    ])
                    
                }
                // 残りのセクション
                PolicySection(title: "7. クッキーおよび追跡技術") {
                    Text("本アプリは、ユーザー体験を向上させるためにクッキーや類似技術を使用する場合があります。ただし、サードパーティの広告やトラッキングを行う場合は、事前にユーザーの同意を取得します。")
                }
                // 残りのセクション
                PolicySection(title: "8. 未成年者の利用") {
                    Text("未成年者（16歳未満）の個人情報は、保護者の同意を得た場合に限り収集します。保護者の同意なしに収集された情報が判明した場合は、速やかに削除します。")
                }
                // 残りのセクション
                PolicySection(title: "9. プライバシーポリシーの変更") {
                    Text("本ポリシーは、随時更新されることがあります。重要な変更がある場合は、本アプリ内で通知します。改定後に本アプリを引き続き利用することで、新しいポリシーに同意したものとみなされます。")
                    
                }
                // TODO: お問い合わせ内容入れる
                PolicySection(title: "10. お問い合わせ") {
                    Text("プライバシーに関するお問い合わせは、以下までご連絡ください：")
                    Text("[運営者名] hotkyou")
                    Text("[メールアドレス] hottarakasi.kyou@gmail.com")
                }
            }
            .padding()
        }
    }
}

// Helper Views
struct PolicySection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .bold()
            content
        }
    }
}

struct SubSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .bold()
            content
        }
    }
}

struct BulletPoint: View {
    let title: String
    let detail: String
    
    init(_ title: String, detail: String) {
        self.title = title
        self.detail = detail
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("• \(title)").bold()
            Text(detail)
                .foregroundColor(.secondary)
                .padding(.leading)
        }
    }
}

struct NumberedList: View {
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Text("\(index + 1). \(item)")
                    .padding(.leading)
            }
        }
    }
}

#Preview {
    PrivacyPolicyView()
}
