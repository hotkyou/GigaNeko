//
//  SettingView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct SettingView: View {
    @State private var toggleState1 = false
    @State private var toggleState2 = true
    
    private let menuItems: [(icon: String, title: String, type: MenuItemType)] = [
        (.init("pencil"), "レビューを書く", .review),
        (.init("square.and.arrow.up"), "アプリをシェアする", .share),
        (.init("exclamationmark.lock"), "利用規約", .terms),
        (.init("hand.raised"), "プライバシーポリシー", .privacy),
        (.init("note.text"), "プラン一覧", .plan),
        (.init("bell"), "通知詳細設定", .notification)
    ]
    
    var body: some View {
        NavigationView{
            ZStack {
                //カラーストップのグラデーション
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 225/255, green: 255/255, blue: 203/255), // #E1FFCB
                        Color(red: 255/255, green: 242/255, blue: 209/255)  // #FFF2D1
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                ).edgesIgnoringSafeArea(.top)
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        Text("設定")
                            .font(.system(size: 34, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        // Menu Items
                        VStack(spacing: 2) {
                            ForEach(menuItems.indices, id: \.self) { index in
                                let item = menuItems[index]
                                MenuItemView(icon: item.icon,
                                             title: item.title,
                                             type: item.type)
                                
                                if index != menuItems.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05),
                                        radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                VStack {
                    Spacer()
                    BannerAd(adUnitID: "ca-app-pub-2291273458039892/3267279868")
                        .frame(height: 50)
                }
            }
        }
    }
}

// Menu Item Type
enum MenuItemType {
    case review, share, terms, privacy, plan, notification
}

// Menu Item View
struct MenuItemView: View {
    let icon: String
    let title: String
    let type: MenuItemType
    
    var body: some View {
        Group {
            switch type {
            case .review:
                Link(destination: URL(string: "https://apps.apple.com/jp/app/id6739386412?action=write-review")!) {
                    menuContent
                }
            case .share:
                ShareLink(item: URL(string: "https://apps.apple.com/jp/app/giganeko/id6739386412")!) {
                    menuContent
                }
            case .terms:
                NavigationLink(destination: TermsView()) {
                    menuContent
                }
            case .privacy:
                NavigationLink(destination: PrivacyPolicyView()) {
                    menuContent
                }
            case .plan:
                NavigationLink(destination: MobilePlansView()) {
                    menuContent
                }
            case .notification:
                NavigationLink(destination: NotificationSettingsView()) {
                    menuContent
                }
            }
        }
    }
    
    private var menuContent: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .padding(.horizontal)
        .frame(height: 54)
    }
}

#Preview {
    SettingView()
}
