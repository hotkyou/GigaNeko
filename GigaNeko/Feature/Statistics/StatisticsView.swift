//
//  StatisticsView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct StatisticsView: View {
    @State private var selectedSegment = "月"
    
    var body: some View {
        ZStack{
            //カラーストップのグラデーション
            Image("StaticBackGround")
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack(spacing: 20) {
                    SegmentButton(title: "日", isSelected: selectedSegment == "日") {
                        selectedSegment = "日"
                    }
                    SegmentButton(title: "週", isSelected: selectedSegment == "週") {
                        selectedSegment = "週"
                    }
                    SegmentButton(title: "月", isSelected: selectedSegment == "月") {
                        selectedSegment = "月"
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
            }
        }
        
    }
}

struct SegmentButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isSelected ? .white : .gray)
                .padding()
                .background(isSelected ? Color.orange : Color.clear)
                .cornerRadius(20)
        }
    }
}

#Preview {
    StatisticsView()
}
