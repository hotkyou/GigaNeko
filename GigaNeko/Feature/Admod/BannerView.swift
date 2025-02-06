//
//  BannerView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2025/02/07.
//

import SwiftUI
import GoogleMobileAds

struct BannerAd: UIViewRepresentable {
    let adUnitID: String
    
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSize(size: CGSize(width: 50, height: 50), flags: 0))
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.windows.first?.rootViewController
        banner.load(Request())
        return banner
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {}
}
