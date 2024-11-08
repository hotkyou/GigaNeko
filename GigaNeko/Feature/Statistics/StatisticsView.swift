import SwiftUI
import Foundation
import Charts

// データ構造体

struct StatisticsView: View {
    @State private var selectedSegment = "日"
    @State private var selectedDataPoint: Date?
    @State private var rawSelectedDate: Date?
    
    private let timeSegments = ["日", "週", "月"]
    @State private var currentDate = Date()
    
    // 週の開始日（日曜日）を取得
    private var weekStartDate: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        return calendar.date(from: components) ?? currentDate
    }
    
    // データ取得用の計算プロパティ
    private var displayData: [(date: Date, wifi: Double, wwan: Double)] {
        switch selectedSegment {
        case "日":
            let hourlyData = loadHourlyDataUsage(for: currentDate)
            return hourlyData.map { usage in
                let date = Calendar.current.date(bySettingHour: usage.hour, minute: 0, second: 0, of: currentDate) ?? currentDate
                return (date, Double(usage.wifi) / 1024 / 1024 / 1024, Double(usage.wwan) / 1024 / 1024 / 1024) // バイトからGBに変換
            }
        case "週":
            let weeklyData = loadWeeklyDataUsage(for: weekStartDate)
            return weeklyData.map { usage in
                let date = Calendar.current.date(byAdding: .day, value: usage.day, to: weekStartDate) ?? currentDate
                return (date, Double(usage.wifi) / 1024 / 1024 / 1024, Double(usage.wwan) / 1024 / 1024 / 1024)
            }
        case "月":
            let monthlyData = loadMonthlyDataUsage(for: currentDate)
            return monthlyData.map { usage in
                let date = Calendar.current.date(bySetting: .day, value: usage.day, of: currentDate) ?? currentDate
                return (date, Double(usage.wifi) / 1024 / 1024 / 1024, Double(usage.wwan) / 1024 / 1024 / 1024)
            }
        default:
            return []
        }
    }
    
    // 選択された期間の統計情報を計算
    private var statistics: (totalWifi: Double, totalWwan: Double, maxTotal: Double) {
        let relevantData: [(date: Date, wifi: Double, wwan: Double)]
        
        switch selectedSegment {
        case "日":
            relevantData = displayData.filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        case "週":
            relevantData = displayData.filter { date in
                let calendar = Calendar.current
                return calendar.isDate(date.date, equalTo: weekStartDate, toGranularity: .weekOfYear)
            }
        case "月":
            relevantData = displayData.filter { date in
                let calendar = Calendar.current
                return calendar.isDate(date.date, equalTo: currentDate, toGranularity: .month)
            }
        default:
            relevantData = []
        }
        
        let totalWifi = relevantData.reduce(0) { $0 + $1.wifi }
        let totalWwan = relevantData.reduce(0) { $0 + $1.wwan }
        let maxTotal = relevantData.map { $0.wifi + $0.wwan }.max() ?? 0
        
        return (totalWifi, totalWwan, maxTotal)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 期間選択セグメント
                    VStack {
                        Picker("期間", selection: $selectedSegment) {
                            ForEach(timeSegments, id: \.self) { segment in
                                Text(segment).tag(segment)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // 日付選択ナビゲーション
                        HStack {
                            Button(action: { moveDate(by: -1) }) {
                                Image(systemName: "chevron.left")
                            }
                            
                            Text(formattedDate)
                                .font(.headline)
                            
                            Button(action: { moveDate(by: 1) }) {
                                Image(systemName: "chevron.right")
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 統計情報カード
                    HStack(spacing: 15) {
                        StatCard(
                            title: "WiFi使用量",
                            value: String(format: "%.2f GB", statistics.totalWifi)
                        )
                        StatCard(
                            title: "モバイル使用量",
                            value: String(format: "%.2f GB", statistics.totalWwan)
                        )
                        StatCard(
                            title: "合計使用量",
                            value: String(format: "%.2f GB", statistics.totalWifi + statistics.totalWwan)
                        )
                    }
                    .padding(.horizontal)
                    
                    // グラフ表示
                    VStack(alignment: .leading) {
                        Text("使用量推移")
                            .font(.headline)
                            .padding(.leading)
                        
                        // Chart部分を更新
                        Chart {
                            ForEach(displayData, id: \.date) { item in
                                // WiFiデータのライン
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("WiFi", item.wifi)
                                )
                                .foregroundStyle(by: .value("Type", "WiFi"))
                                .interpolationMethod(.catmullRom)
                                
                                // モバイルデータのライン
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Mobile", item.wwan)
                                )
                                .foregroundStyle(by: .value("Type", "モバイル"))
                                .interpolationMethod(.catmullRom)
                            }
                            
                            if let selectedDate = rawSelectedDate {
                                RuleMark(x: .value("Selected", selectedDate))
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .annotation(position: .top) {
                                        if let dataPoint = displayData.first(where: { Calendar.current.isDate($0.date, equalTo: selectedDate, toGranularity: getGranularity()) }) {
                                            VStack {
                                                Text(dataPoint.date, format: getDateFormat())
                                                    .font(.caption)
                                                Text("WiFi: \(String(format: "%.2f GB", dataPoint.wifi))")
                                                    .foregroundColor(.blue)
                                                Text("Mobile: \(String(format: "%.2f GB", dataPoint.wwan))")
                                                    .foregroundColor(.orange)
                                            }
                                            .padding(8)
                                            .background(Color(.systemBackground))
                                            .cornerRadius(8)
                                        }
                                    }
                            }
                        }
                        .chartForegroundStyleScale([
                            "WiFi": .blue,
                            "モバイル": .orange
                        ])
                        .chartXScale(domain: getChartDateRange())
                        .chartXAxis {
                            AxisMarks(values: .stride(by: getStrideBy())) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel {
                                        Text(date, format: getAxisLabelFormat())
                                    }
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                AxisValueLabel {
                                    if let doubleValue = value.as(Double.self) {
                                        Text(String(format: "%.1f GB", doubleValue))
                                    }
                                }
                            }
                        }
                        .chartXSelection(value: $rawSelectedDate)
                        .frame(height: 300)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 2)
                        )
                        
                        // 凡例
                        HStack {
                            Label("WiFi", systemImage: "circle.fill")
                                .foregroundColor(.blue)
                            Spacer()
                            Label("モバイル", systemImage: "circle.fill")
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle("データ使用量統計")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // ヘルパー関数
    private func moveDate(by value: Int) {
        switch selectedSegment {
        case "日":
            currentDate = Calendar.current.date(byAdding: .day, value: value, to: currentDate) ?? currentDate
        case "週":
            currentDate = Calendar.current.date(byAdding: .weekOfYear, value: value, to: currentDate) ?? currentDate
        case "月":
            currentDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) ?? currentDate
        default:
            break
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        switch selectedSegment {
        case "日":
            formatter.dateFormat = "yyyy年M月d日"
        case "週":
            formatter.dateFormat = "yyyy年M月d日"
            let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? currentDate
            let endFormatter = DateFormatter()
            endFormatter.dateFormat = "d日"
            return "\(formatter.string(from: weekStartDate)) - \(endFormatter.string(from: weekEnd))"
        case "月":
            formatter.dateFormat = "yyyy年M月"
        default:
            formatter.dateFormat = "yyyy年M月d日"
        }
        return formatter.string(from: currentDate)
    }
    
    private func getDateFormat() -> Date.FormatStyle {
        switch selectedSegment {
        case "日":
            return .dateTime.hour()
        case "週":
            return .dateTime.weekday()
        case "月":
            return .dateTime.month().day()
        default:
            return .dateTime.month().day()
        }
    }
    
    private func getAxisLabelFormat() -> Date.FormatStyle {
        switch selectedSegment {
        case "日":
            return .dateTime.hour()
        case "週":
            return .dateTime.weekday(.abbreviated)
        case "月":
            return .dateTime.day()
        default:
            return .dateTime.day()
        }
    }
    
    private func getStrideBy() -> Calendar.Component {
        switch selectedSegment {
        case "日":
            return .hour
        case "週", "月":
            return .day
        default:
            return .day
        }
    }
    
    private func getGranularity() -> Calendar.Component {
        switch selectedSegment {
        case "日":
            return .hour
        case "週", "月":
            return .day
        default:
            return .day
        }
    }
    
    private func getChartDateRange() -> ClosedRange<Date> {
        let calendar = Calendar.current
        switch selectedSegment {
        case "日":
            let startDate = calendar.startOfDay(for: currentDate)
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? currentDate
            return startDate...endDate
        case "週":
            let endDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate) ?? currentDate
            return weekStartDate...endDate
        case "月":
            let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? currentDate
            let endDate = calendar.date(byAdding: .month, value: 1, to: startDate) ?? currentDate
            return startDate...endDate
        default:
            return currentDate...currentDate
        }
    }
}

// 統計カードビュー
struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
    }
}

// Preview
struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
