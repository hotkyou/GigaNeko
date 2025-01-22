//
//  TermsView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/11/18.
//

import SwiftUI

struct TermsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダー
                Text("利用規約")
                    .font(.system(size: 28, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                
                // 前文
                Text("この利用規約（以下「本規約」といいます）は、[アプリ名]（以下「本アプリ」といいます）をご利用いただく際の条件を定めるものです。本アプリをご利用いただく前に、以下の規約をよくお読みください。本アプリをダウンロードまたは使用することにより、本規約に同意いただいたものとみなします。")
                    .lineSpacing(6)
                
                // 各条項
                ForEach(termsData) { section in
                    TermsSection(section: section)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

// 条項のセクションビュー
struct TermsSection: View {
    let section: TermsContent
    
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
            
            // サブ項目がある場合
            if let items = section.items {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .frame(width: 20, alignment: .leading)
                            Text(item)
                        }
                        .lineSpacing(6)
                    }
                }
                .padding(.leading, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// 利用規約のデータモデル
struct TermsContent: Identifiable {
    let id = UUID()
    let title: String
    let mainText: String?
    let items: [String]?
}

// 利用規約のデータ
let termsData: [TermsContent] = [
    TermsContent(
        title: "第1条（適用範囲）",
        mainText: "本規約は、本アプリを利用するすべてのユーザー（以下「ユーザー」といいます）に適用されます。",
        items: nil
    ),
    TermsContent(
        title: "第2条（サービス内容）",
        mainText: "本アプリは、モバイル通信量をポイントとして換算し、そのポイントを使用してバーチャルペットである「猫」を育成するゲーム体験を提供します。具体的なサービス内容は、本アプリ内に別途記載します。",
        items: nil
    ),
    TermsContent(
        title: "第3条（利用条件）",
        mainText: nil,
        items: [
            "ユーザーは、本アプリを利用するにあたり、以下を遵守するものとします：\n・本規約および関連法令を遵守すること。\n・不正な手段でモバイル通信データを改ざんしないこと。\n・他のユーザーや第三者の権利を侵害しないこと。",
            "本アプリの一部機能を利用するためには、インターネット接続および適切なデバイスが必要です。"
        ]
    ),
    TermsContent(
        title: "第4条（ポイントの利用）",
        mainText: nil,
        items: [
            "モバイル通信データをポイントに変換する仕組みは、本アプリが指定する方法に基づきます。",
            "ポイントはアプリ内のみに有効であり、現金やその他の通貨に交換することはできません。",
            "ポイントの譲渡、売買、または他人への移転は禁止されています。"
        ]
    ),
    TermsContent(
        title: "第5条（禁止事項）",
        mainText: nil,
        items: [
            "ユーザーは、本アプリの利用にあたり、以下の行為を行ってはなりません：",
            "不正な手段でポイントを取得または増加させる行為。",
            "本アプリの運営を妨害する行為。",
            "本アプリのソースコードを解析、改変、リバースエンジニアリングする行為。"
        ]
    ),
    TermsContent(
        title: "第6条（免責事項）",
        mainText: nil,
        items: [
            "本アプリは、モバイル通信データの正確性やポイント換算の精度を保証しません。",
            "本アプリの利用に関連して生じた損害について、運営者は一切の責任を負いません", "ただし、適用法令により免責が認められない場合を除きます。"
        ]
    ),
    TermsContent(
        title: "第7条（プライバシー）",
        mainText: nil,
        items: [
            "本アプリの利用を通じて取得したユーザー情報は、本アプリの[プライバシーポリシー]に従って適切に取り扱います。"
        ]
    ),
    TermsContent(
        title: "第8条（利用制限および停止）",
        mainText: nil,
        items: [
            "運営者は、ユーザーが本規約に違反した場合、または運営上必要と判断した場合、事前通知なくアカウントの一時停止または利用制限を行うことができます。"
            

        ]
    ),
    TermsContent(
        title: "第9条（サービスの変更・終了）",
        mainText: nil,
        items: [
            "運営者は、ユーザーへの事前通知をもって、本アプリの内容変更または提供を終了することができます。",
            "サービスの変更または終了により生じた損害について、運営者は一切責任を負いません。"
        ]
    ),
    TermsContent(
        title: "第10条（準拠法および裁判管轄）",
        mainText: nil,
        items: [
            "本規約の準拠法は、日本法とします",
            "本規約に関する紛争については、[運営者所在地を管轄する裁判所]を第一審の専属的合意管轄裁判所とします。"
        ]
    ),
]

#Preview {
    TermsView()
}
