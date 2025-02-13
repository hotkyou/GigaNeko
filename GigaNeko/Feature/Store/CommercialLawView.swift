import SwiftUI

struct CommercialLawView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダー
                Text("特定商取引法に基づく表記")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                
                // 各条項
                ForEach(commercialLawData) { section in
                    LawSection(section: section)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// 条項のセクションビュー
struct LawSection: View {
    let section: LawContent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 条項タイトル
            Text(section.title)
                .font(.system(size: 18, weight: .bold))
            
            // 条項本文
            if let mainText = section.mainText {
                Text(mainText)
                    .lineSpacing(6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// データモデル
struct LawContent: Identifiable {
    let id = UUID()
    let title: String
    let mainText: String?
}

// 特定商取引法データ
let commercialLawData: [LawContent] = [
    LawContent(title: "責任者名", mainText: "堀田 恭之介"),
    LawContent(title: "所在地", mainText: "〒123-0852 東京都足立区関原2-35-20Ambition103"),
    LawContent(title: "お問い合わせ先", mainText: "電話: 080-8476-0541\nメール: hottarakasi.kyou@gmail.com"),
    LawContent(title: "販売価格", mainText: "購入手続きの際に画面に表示されます。"),
    LawContent(title: "販売代金以外の必要料金", mainText: "電気通信回線の通信料金等（インターネット接続料金含む）\n※料金はご利用のインターネットプロバイダー等にお問い合わせください"),
    LawContent(title: "支払い方法", mainText: "Appleに準じます。"),
    LawContent(title: "返品・交換について", mainText: "デジタルコンテンツの返品・交換は受け付けておりません。"),
    LawContent(title: "提供時期", mainText: "決済完了後"),
    LawContent(title: "お支払い時期", mainText: "Appleの定める時期に準じます。"),
    LawContent(title: "動作環境", mainText: "Appleのアプリページに記載しております。")
]

#Preview {
    CommercialLawView()
}
