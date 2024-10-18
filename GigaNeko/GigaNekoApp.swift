//
//  GigaNekoApp.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/17.
//

import SwiftUI
import Firebase

@main
struct GigaNekoApp: App {
    // Firebaseの初期化
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
