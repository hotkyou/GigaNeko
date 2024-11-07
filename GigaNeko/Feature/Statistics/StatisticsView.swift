import SwiftUI
import Foundation

struct StatisticsView: View {
    @State private var selectedSegment = "月"
    @State private var selectedTab: String = "グラフ"
    
    @State private var hourlyData: [HourlyDataUsage] = []
    @State private var weeklyData: [DailyDataUsage] = []
    @State private var monthlyData: [DailyDataUsage] = []
    
    let maxData: CGFloat = 5 // Max value for y-axis scaling
    
    var body: some View {
        ZStack {
            Image("StaticBackGround")
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack(spacing: 20) {
                    Text("グラフ")
                        .padding(.leading, 10)
                        .padding(.horizontal, 14)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "グラフ"
                            loadData()
                        }
                    Text("りれき")
                        .padding(.leading, 10)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "りれき"
                        }
                }
                .padding(.top, 112)
                .padding(.bottom, 20)
                
                if selectedTab == "グラフ" {
                    // Segment buttons for 日, 週, 月
                    HStack(spacing: 20) {
                        SegmentButton(title: "日", isSelected: selectedSegment == "日") {
                            selectedSegment = "日"
                            loadData()
                        }
                        SegmentButton(title: "週", isSelected: selectedSegment == "週") {
                            selectedSegment = "週"
                            loadData()
                        }
                        SegmentButton(title: "月", isSelected: selectedSegment == "月") {
                            selectedSegment = "月"
                            loadData()
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.bottom, 16)
                    
                    VStack {
                        Text("2024年 10月")
                            .font(.headline)
                            .padding(.bottom, 16)
                        
                        GeometryReader { geometry in
                            ZStack {
                                ForEach(0..<5) { i in
                                    let y = geometry.size.height / CGFloat(5) * CGFloat(i)
                                    Path { path in
                                        path.move(to: CGPoint(x: 0, y: y))
                                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                                    }
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                }
                                
                                // Draw the usage line based on selected segment
                                Path { path in
                                    let dataUsage = getDataUsageForCurrentSegment()
                                    let step = geometry.size.width / CGFloat(dataUsage.count - 1)
                                    
                                    for index in dataUsage.indices {
                                        let x = step * CGFloat(index)
                                        let y = (1 - CGFloat(dataUsage[index]) / maxData) * geometry.size.height
                                        if index == 0 {
                                            path.move(to: CGPoint(x: x, y: y))
                                        } else {
                                            path.addLine(to: CGPoint(x: x, y: y))
                                        }
                                    }
                                }
                                .stroke(Color.orange, lineWidth: 2)
                            }
                        }
                        .frame(height: 100)
                    }
                    .padding(.bottom)
                    
                    // Other UI components (omitted for brevity)
                } else if selectedTab == "りれき" {
                    // 'りれき' tab UI (omitted for brevity)
                }
                
                Spacer()
            }
            .padding(.leading, 64)
            .padding(.trailing, 74)
        }
    }
    
    // Segment-specific data loading
    private func loadData() {
        let currentDate = Date()
        switch selectedSegment {
        case "日":
            hourlyData = loadHourlyDataUsage(for: currentDate)
        case "週":
            let startOfWeek = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate))!
            weeklyData = loadWeeklyDataUsage(for: startOfWeek)
        case "月":
            monthlyData = loadMonthlyDataUsage(for: currentDate)
        default:
            break
        }
    }
    
    // Get data usage array based on selected segment
    private func getDataUsageForCurrentSegment() -> [UInt64] {
        switch selectedSegment {
        case "日":
            return hourlyData.map { $0.wifi + $0.wwan }
        case "週":
            return weeklyData.map { $0.wifi + $0.wwan }
        case "月":
            return monthlyData.map { $0.wifi + $0.wwan }
        default:
            return []
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
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(isSelected ? Color.orange : Color.clear)
                .cornerRadius(15)
        }
    }
}

// Additional structs and previews
#Preview {
    StatisticsView()
}
