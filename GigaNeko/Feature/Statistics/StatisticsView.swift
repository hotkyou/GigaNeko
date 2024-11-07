//
//  StatisticsView.swift
//  GigaNeko
//
//  Created by 水原　樹 on 2024/10/18.
//

import SwiftUI

struct StatisticsView: View {
    @State private var selectedSegment = "月"
    @State private var selectedTab: String = "グラフ"
    
    let dataUsage: [CGFloat] = [0, 0.5, 1.2, 2.0, 3.5, 4.0] // Example data usage points
    let wifiUsage: [CGFloat] = [0, 0.8, 1.0, 1.5, 2.0, 2.2] // Example Wi-Fi usage points
    let maxData: CGFloat = 5 // Max value for y-axis scaling
    
    var body: some View {
        ZStack{
            //カラーストップのグラデーション
            Image("StaticBackGround")
                .edgesIgnoringSafeArea(.all)
            VStack{
                HStack(spacing: 20){
                    Text("グラフ")
                        .padding(.leading,10)
                        .padding(.horizontal,14)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "グラフ"
                        }
                    Text("りれき")
                        .padding(.leading,10)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "りれき"
                        }
                    
                }
                .padding(.top,112)
                .padding(.bottom,20)
                if selectedTab == "グラフ" {
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
                    .padding(.bottom,16)
                    
                    
                    VStack{
                        Text("2024年 10月")
                            .font(.headline)
                            .padding(.bottom, 16)
                        
                        GeometryReader { geometry in
                            ZStack {
                                // Y-axis grid lines
                                ForEach(0..<5) { i in
                                    let y = geometry.size.height / CGFloat(5) * CGFloat(i)
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                                    }
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                }
                                
                                // Data Usage Line
                                Path { path in
                                    let step = geometry.size.width / CGFloat(dataUsage.count - 1)
                                    for index in dataUsage.indices {
                                        let x = step * CGFloat(index)
                                        let y = (1 - dataUsage[index] / maxData) * geometry.size.height
                                        if index == 0 {
                                            path.move(to: CGPoint(x: x, y: y))
                                        } else {
                                            path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                }
                                .stroke(Color.orange, lineWidth: 2)
                                
                                // Wi-Fi Usage Line
                                Path { path in
                                    let step = geometry.size.width / CGFloat(wifiUsage.count - 1)
                                    for index in wifiUsage.indices {
                                        let x = step * CGFloat(index)
                                        let y = (1 - wifiUsage[index] / maxData) * geometry.size.height
                                        if index == 0 {
                                            path.move(to: CGPoint(x: x, y: y))
                                        } else {
                                            path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                }
                                .stroke(Color.green, lineWidth: 2)
                                
                                // Data points and labels
                                ForEach(dataUsage.indices, id: \.self) { index in
                                    let step = geometry.size.width / CGFloat(dataUsage.count - 1)
                                    let x = step * CGFloat(index)
                                    let y = (1 - dataUsage[index] / maxData) * geometry.size.height
                                    Circle()
                                        .fill(Color.orange)
                                        .frame(width: 6, height: 6)
                                        .position(x: x, y: y)
                                    
                                    if index == dataUsage.count - 2 {
                                        Text("3.5 GB\n10/14")
                                            .font(.caption)
                                            .padding(5)
                                            .background(Color(UIColor.systemGray6))
                                            .cornerRadius(5)
                                            .position(x: x, y: y - 20)
                                    }
                                }
                            }
                        }
                        .frame(height: 100)
                        
                        // Legend
                        HStack {
                            HStack {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 10, height: 10)
                                Text("通信量")
                                    .font(.caption)
                            }
                            .padding(.trailing)
                            
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 10, height: 10)
                                Text("Wi-Fi")
                                    .font(.caption)
                            }
                        }
                        .padding(.top, 10)
                    }// WiFIのVStack
                    .padding(.bottom)
                    
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("2024/10")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "person.fill") // Replace with your custom image
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            UsageColumn(title: "使った通信量", amount: "5", unit: "GB")
                            UsageColumn(title: "残っている通信量", amount: "2", unit: "GB")
                            UsageColumn(title: "Wi-Fi", amount: "3", unit: "GB")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .frame(width: 250)
                } else if selectedTab == "りれき" {
                    VStack(spacing: 20) {
                        // ヘッダー部分
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.3))
                                .frame(width: 5, height: 25)
                            
                            Text("りれき")
                                .font(.headline)
                                .foregroundColor(.white) // 文字色を白に設定
                                .padding(.horizontal, 60)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading) // 左寄せに設定
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        // タイトル行
                        HStack {
                            Text("日付")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("通信量")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("取得ポイント")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // データ行
                        ForEach(0..<3) { _ in
                            HStack {
                                Text("2024/10/01")
                                Spacer()
                                Text("0.5GB")
                                Spacer()
                                Text("50")
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            
                            Divider()
                                .background(Color.gray.opacity(0.5))
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
                
                Spacer()
            }
            .padding(.leading, 64)
            .padding(.trailing, 74)
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
                .font(.system(size: 14, weight: .medium)) // Adjust font as needed
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(isSelected ? Color.orange : Color.clear)
                .cornerRadius(15)
        }
    }
}


struct UsageColumn: View {
    let title: String
    let amount: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.gray)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(amount)
                    .font(.title)
                    .fontWeight(.bold)
                Text(unit)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}


#Preview {
    StatisticsView()
}
