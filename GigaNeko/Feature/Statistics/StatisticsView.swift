import SwiftUI
import Charts
import Foundation

// MARK: - 列挙型と構造体
enum TimeSegment: String, CaseIterable {
    case daily = "日"
    case weekly = "週"
    case monthly = "月"
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        }
    }
    
    var strideComponent: Calendar.Component {
        switch self {
        case .daily: return .hour
        case .weekly, .monthly: return .day
        }
    }
    
    var granularity: Calendar.Component {
        switch self {
        case .daily: return .hour
        case .weekly, .monthly: return .day
        }
    }
}

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let wifi: Double
    let wwan: Double
    
    var total: Double { wifi + wwan }
}

// MARK: - StatisticsView
struct StatisticsView: View {
    // MARK: - Properties
    @State private var selectedSegment: TimeSegment = .daily
    @State private var selectedTab: String = "グラフ"
    @State private var selectedDataPoint: Date?
    @State private var rawSelectedDate: Date?
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    
    // MARK: - Computed Properties
    private var weekStartDate: Date {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)
        return calendar.date(from: components) ?? currentDate
    }
    
    private var displayData: [DataPoint] {
        switch selectedSegment {
        case .daily:
            return loadHourlyData()
        case .weekly:
            return loadWeeklyData()
        case .monthly:
            return loadMonthlyData()
        }
    }
    
    private var statistics: (totalWifi: Double, totalWwan: Double, maxTotal: Double) {
        let relevantData = filterDataForCurrentPeriod()
        let totalWifi = relevantData.reduce(0) { $0 + $1.wifi }
        let totalWwan = relevantData.reduce(0) { $0 + $1.wwan }
        let maxTotal = relevantData.map(\.total).max() ?? 0
        
        return (totalWifi, totalWwan, maxTotal)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Image("StaticBackGround")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // タブ選択
                HStack(spacing: 20) {
                    Text("グラフ")
                        .padding(.leading, 10)
                        .padding(.horizontal, 14)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "グラフ"
                        }
                    Text("りれき")
                        .padding(.leading, 10)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "りれき"
                        }
                }
                .padding(.top, 92)
                .padding(.bottom, 20)
                
                if selectedTab == "グラフ" {
                    // セグメントコントロール
                    HStack(spacing: 20) {
                        ForEach(TimeSegment.allCases, id: \.self) { segment in
                            SegmentButton(
                                title: segment.rawValue,
                                isSelected: selectedSegment == segment
                            ) {
                                selectedSegment = segment
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .padding(.bottom, 16)
                    
                    // 日付ナビゲーション
                    HStack {
                        NavigationButton(systemName: "chevron.left") {
                            moveDate(by: -1)
                        }
                        
                        Spacer()
                        
                        Text(formattedDate)
                            .font(.headline)
                        
                        Spacer()
                        
                        NavigationButton(systemName: "chevron.right") {
                            moveDate(by: 1)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    // グラフ部分
                    VStack {
                        Chart {
                            ForEach(displayData) { item in
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("WiFi", item.wifi)
                                )
                                .foregroundStyle(by: .value("Type", "WiFi"))
                                .interpolationMethod(.linear)
                                
                                LineMark(
                                    x: .value("Date", item.date),
                                    y: .value("Mobile", item.wwan)
                                )
                                .foregroundStyle(by: .value("Type", "モバイル"))
                                .interpolationMethod(.linear)
                            }
                            
                            if let selectedDate = rawSelectedDate {
                                RuleMark(x: .value("Selected", selectedDate))
                                    .foregroundStyle(.gray.opacity(0.3))
                                    .annotation(position: .top) {
                                        selectedDataAnnotation(for: selectedDate)
                                    }
                            }
                        }
                        .chartForegroundStyleScale([
                            "WiFi": .green,
                            "モバイル": .orange
                        ])
                        .chartXScale(domain: getChartDateRange())
                        .chartYScale(domain: 0...(statistics.maxTotal * 1.2))
                        .chartXAxis(content: customXAxis)
                        .chartYAxis(content: customYAxis)
                        .chartXSelection(value: $rawSelectedDate)
                        .frame(height: 100)
                        
                        // 凡例
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
                    }
                    .padding(.bottom)
                    
                    // 使用量サマリー
                    VStack(spacing: 10) {
                        HStack {
                            Text(String(format: "%d/%d", calendar.component(.month, from: currentDate), calendar.component(.year, from: currentDate)))
                                .font(.title3)
                                .foregroundColor(.gray)
                            Spacer()
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            UsageColumn(title: "使った通信量",
                                      amount: String(format: "%.1f", statistics.totalWwan),
                                      unit: "GB")
                            UsageColumn(title: "残っている通信量",
                                      amount: String(format: "%.1f", 7 - statistics.totalWwan),
                                      unit: "GB")
                            UsageColumn(title: "Wi-Fi",
                                      amount: String(format: "%.1f", statistics.totalWifi),
                                      unit: "GB")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .frame(width: 250)
                    
                } else if selectedTab == "りれき" {
                    // 履歴ビューの実装
                    VStack(spacing: 20) {
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.green.opacity(0.3))
                                .frame(width: 5, height: 25)
                            
                            Text("りれき")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 60)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
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
                        
                        ForEach(displayData.prefix(5), id: \.id) { item in
                            HStack {
                                Text(item.date, format: .dateTime.year().month().day())
                                Spacer()
                                Text(String(format: "%.2f GB", item.total))
                                Spacer()
                                Text(String(Int(item.total * 100)))
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
            .padding(.top, 30)
        }
    }
    
    // MARK: - Helper Methods
    private func loadHourlyData() -> [DataPoint] {
        let hourlyData = loadHourlyDataUsage(for: currentDate)
        return hourlyData.map { usage in
            let date = calendar.date(bySettingHour: usage.hour, minute: 0, second: 0, of: currentDate) ?? currentDate
            return DataPoint(
                date: date,
                wifi: Double(usage.wifi) / 1024 / 1024 / 1024,
                wwan: Double(usage.wwan) / 1024 / 1024 / 1024
            )
        }
    }
    
    private func loadWeeklyData() -> [DataPoint] {
        let weeklyData = loadWeeklyDataUsage(for: weekStartDate)
        return weeklyData.map { usage in
            let date = calendar.date(byAdding: .day, value: usage.day, to: weekStartDate) ?? currentDate
            return DataPoint(
                date: date,
                wifi: Double(usage.wifi) / 1024 / 1024 / 1024,
                wwan: Double(usage.wwan) / 1024 / 1024 / 1024
            )
        }
    }
    
    private func loadMonthlyData() -> [DataPoint] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return []
        }
        
        let monthlyData = loadMonthlyDataUsage(for: startOfMonth)
        return monthlyData.map { usage in
            guard let date = calendar.date(byAdding: .day, value: usage.day - 1, to: startOfMonth) else {
                return DataPoint(date: currentDate, wifi: 0, wwan: 0)
            }
            return DataPoint(
                date: date,
                wifi: Double(usage.wifi) / 1024 / 1024 / 1024,
                wwan: Double(usage.wwan) / 1024 / 1024 / 1024
            )
        }
    }
    
    private func filterDataForCurrentPeriod() -> [DataPoint] {
        switch selectedSegment {
        case .daily:
            return displayData.filter { calendar.isDate($0.date, inSameDayAs: currentDate) }
        case .weekly:
            return displayData.filter { calendar.isDate($0.date, equalTo: weekStartDate, toGranularity: .weekOfYear) }
        case .monthly:
            return displayData.filter { calendar.isDate($0.date, equalTo: currentDate, toGranularity: .month) }
        }
    }
    
    private func moveDate(by value: Int) {
        if let newDate = calendar.date(byAdding: selectedSegment.calendarComponent, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func getChartDateRange() -> ClosedRange<Date> {
        switch selectedSegment {
        case .daily:
            let startDate = calendar.startOfDay(for: currentDate)
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? currentDate
            return startDate...endDate
            
        case .weekly:
            let endDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate) ?? currentDate
            return weekStartDate...endDate
            
        case .monthly:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth),
                  let endDate = calendar.date(byAdding: .day, value: 1, to: endOfMonth) else {
                return currentDate...currentDate
            }
            return startOfMonth...endDate
        }
    }
    
    private func customXAxis() -> some AxisContent {
        AxisMarks(preset: .aligned, values: .stride(by: selectedSegment.strideComponent)) { value in
            if let date = value.as(Date.self) {
                AxisGridLine()
                AxisTick()
                AxisValueLabel {
                    switch selectedSegment {
                    case .daily:
                        // 日次表示の場合、3時間おきに表示
                        let hour = calendar.component(.hour, from: date)
                        if hour % 3 == 0 {
                            Text(date, format: .dateTime.hour())
                                .font(.caption)
                        }
                    case .weekly:
                        Text(date, format: .dateTime.weekday(.abbreviated))
                            .font(.caption)
                    case .monthly:
                        // 月次表示の場合、5日おきに表示
                        let day = calendar.component(.day, from: date)
                        if day % 5 == 0 || day == 1 {
                            Text("\(day)日")
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
    
    private func customYAxis() -> some AxisContent {
        AxisMarks(position: .leading, values: .automatic(desiredCount: 5)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel {
                if let doubleValue = value.as(Double.self) {
                    Text(String(format: "%.1f GB", doubleValue))
                        .font(.caption)
                }
            }
        }
    }
    
    private func selectedDataAnnotation(for date: Date) -> some View {
        Group {
            if let dataPoint = displayData.first(where: {
                calendar.isDate($0.date, equalTo: date, toGranularity: selectedSegment.granularity)
            }) {
                VStack {
                    Text(dataPoint.date, format: getDateFormat())
                        .font(.caption)
                    Text("WiFi: \(String(format: "%.2f GB", dataPoint.wifi))")
                        .foregroundColor(.green)
                    Text("Mobile: \(String(format: "%.2f GB", dataPoint.wwan))")
                        .foregroundColor(.orange)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        switch selectedSegment {
        case .daily:
            formatter.dateFormat = "yyyy年M月d日"
            return formatter.string(from: currentDate)
            
        case .weekly:
            formatter.dateFormat = "yyyy年M月d日"
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStartDate) ?? currentDate
            let endFormatter = DateFormatter()
            endFormatter.dateFormat = "d日"
            return "\(formatter.string(from: weekStartDate)) - \(endFormatter.string(from: weekEnd))"
            
        case .monthly:
            formatter.dateFormat = "yyyy年M月"
            return formatter.string(from: currentDate)
        }
    }
    
    private func getDateFormat() -> Date.FormatStyle {
        switch selectedSegment {
        case .daily:
            return .dateTime.hour()
        case .weekly:
            return .dateTime.weekday()
        case .monthly:
            return .dateTime.month().day()
        }
    }
    
    private func getAxisLabelFormat() -> Date.FormatStyle {
        switch selectedSegment {
        case .daily:
            return .dateTime.hour()
        case .weekly:
            return .dateTime.weekday(.abbreviated)
        case .monthly:
            return .dateTime.day()
        }
    }
}

// MARK: - StatCard View
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

struct NavigationButton: View {
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.orange)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                )
        }
    }
}
