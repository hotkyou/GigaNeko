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
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: currentDate) + "の使用状況"
    }
    
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
    
    private var monthlyStatistics: (totalWifi: Double, totalWwan: Double, maxTotal: Double) {
        // 現在の月の開始日を取得
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return (0, 0, 0)
        }
        
        // 月末日を取得
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return (0, 0, 0)
        }
        
        // 月間データを読み込む
        let monthlyData = loadMonthlyDataUsage(for: startOfMonth)
        
        let totalWifi = monthlyData.reduce(0) { $0 + Double($1.wifi) / 1024 / 1024 / 1024 }
        let totalWwan = monthlyData.reduce(0) { $0 + Double($1.wwan) / 1024 / 1024 / 1024 }
        let maxTotal = monthlyData.map { Double($0.wifi + $0.wwan) / 1024 / 1024 / 1024 }.max() ?? 0
        
        return (totalWifi, totalWwan, maxTotal)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            Image("StaticBackGround")
                .edgesIgnoringSafeArea(.all)
            
            // FUCK: 画面遷移した時に謎に下にいくから調整
            // 原因は画面遷移した時のBackが邪魔で
            // ごめんなせえ
            VStack{
                HStack(spacing: 20){
                    Text("グラフ")
                        .font(.system(size: 16, weight: selectedTab == "グラフ" ? .bold : .regular))
                        .foregroundColor(selectedTab == "グラフ" ? .primary : .gray)
                        .padding(.leading, 10)
                        .padding(.horizontal, 14)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "グラフ"
                        }
                    Text("りれき")
                        .font(.system(size: 16, weight: selectedTab == "りれき" ? .bold : .regular))
                        .foregroundColor(selectedTab == "りれき" ? .primary : .gray)
                        .padding(.leading, 10)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedTab = "りれき"
                        }
                }
                .padding(.top, 92)
                .padding(.bottom, 20)
                
                if selectedTab == "グラフ" {
                    VStack(spacing: 8) { // 全体のスペーシングを減少
                        // グラフのヘッダー
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: 5, height: 18) // 高さを減少
                            
                            Text("データ使用量")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 5) // パディングを減少
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 30) // パディングを調整して横幅を揃える
                        
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
                        .padding(.horizontal, 10) // パディングを調整
                        .padding(.vertical, 6) // パディングを減少
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                        
                        // 日付ナビゲーション
                        HStack {
                            NavigationButton(systemName: "chevron.left") {
                                moveDate(by: -1)
                            }
                            
                            Spacer()
                            
                            Text(formattedDate)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            NavigationButton(systemName: "chevron.right") {
                                moveDate(by: 1)
                            }
                        }
                        .padding(.horizontal, 12) // パディングを調整して横幅を揃える
                        .padding(.vertical, 6) // パディングを減少
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(15)
                        
                        // グラフ部分
                        VStack(spacing: 4) {
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
                                "WiFi": Color.green,
                                "モバイル": Color.orange
                            ])
                            .chartLegend(position: .bottom, alignment: .center)
                            .chartXScale(domain: getChartDateRange())
                            .chartYScale(domain: 0...(statistics.maxTotal * 1.2))
                            .chartXAxis(content: customXAxis)
                            .chartYAxis(content: customYAxis)
                            .chartXSelection(value: $rawSelectedDate)
                            .frame(height: 200)
                            .padding(6)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        }
                        .padding(.vertical, 4)
                        // スワイプジェスチャーを追加
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    let threshold: CGFloat = 50 // スワイプを検知する閾値
                                    if value.translation.width > threshold {
                                        // 右にスワイプ -> 前の日付へ
                                        moveDate(by: -1)
                                    } else if value.translation.width < -threshold {
                                        // 左にスワイプ -> 次の日付へ
                                        moveDate(by: 1)
                                    }
                                }
                        )
                        // 使用量サマリー
                        VStack(spacing: 4) { // スペーシングを減少
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 5, height: 18) // 高さを減少
                                
                                Text(monthTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 3) // パディングを減少
                                    .background(Color.orange.opacity(0.3))
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 12) // パディングを調整して横幅を揃える
                            
                            VStack(spacing: 4) { // スペーシングを減少
                                VerticalSummaryCard(
                                    title: "使った通信量",
                                    value: String(format: "%.1f GB", monthlyStatistics.totalWwan),
                                    color: .orange
                                )
                                
                                VerticalSummaryCard(
                                    title: "残っている通信量",
                                    value: String(format: "%.1f GB", max(0, 7 - monthlyStatistics.totalWwan)),
                                    color: .orange
                                )
                                
                                VerticalSummaryCard(
                                    title: "Wi-Fi使用量",
                                    value: String(format: "%.1f GB", monthlyStatistics.totalWifi),
                                    color: .green
                                )
                            }
                            .padding(.horizontal, 12) // パディングを調整して横幅を揃える
                        }
                        .padding(6) // パディングを減少
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                    
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
        // 日曜日から土曜日までの7日間のデータを生成
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
            // 終了日を次の日の00:00に設定（24時間表示のため）
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
                return startDate...startDate
            }
            return startDate...endDate
            
        case .weekly:
            // 週の開始日（日曜日）
            let startDate = weekStartDate
            // 週の終了日（土曜日の終わり）
            guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
                return startDate...startDate
            }
            // 土曜日の23:59:59まで表示
            guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
                return startDate...startDate
            }
            return startDate...endOfDay
            
        case .monthly:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
                return currentDate...currentDate
            }
            // 月の最終日を取得
            guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                return startOfMonth...startOfMonth
            }
            // 月末の23:59:59まで表示
            guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) else {
                return startOfMonth...startOfMonth
            }
            return startOfMonth...endOfDay
        }
    }

    private func customXAxis() -> some AxisContent {
        AxisMarks(preset: .aligned, values: .stride(by: selectedSegment.strideComponent)) { value in
            if let date = value.as(Date.self) {
                let shouldShowLabel: Bool = {
                    switch selectedSegment {
                    case .daily:
                        let hour = calendar.component(.hour, from: date)
                        return hour % 3 == 0
                    case .weekly:
                        let weekday = calendar.component(.weekday, from: date)
                        return weekday >= 1 && weekday <= 7
                    case .monthly:
                        let day = calendar.component(.day, from: date)
                        let isLastDayOfMonth = calendar.isDate(date, equalTo: getChartDateRange().upperBound, toGranularity: .day)
                        
                        // 月末が30日または31日の場合の特別処理
                        if day >= 30 {
                            return isLastDayOfMonth  // 月末日のみ表示
                        }
                        
                        // それ以外の日は5の倍数と1日を表示
                        return day % 5 == 0 || day == 1
                    }
                }()
                
                if shouldShowLabel {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1))
                        .foregroundStyle(Color.gray.opacity(0.5))
                    AxisTick(stroke: StrokeStyle(lineWidth: 1.5))
                    AxisValueLabel {
                        switch selectedSegment {
                        case .daily:
                            let hour = calendar.component(.hour, from: date)
                            Text("\(hour)")
                                .font(.caption)
                        case .weekly:
                            Text(date, format: .dateTime.weekday(.abbreviated))
                                .font(.caption)
                        case .monthly:
                            let day = calendar.component(.day, from: date)
                            Text("\(day)")
                                .font(.caption)
                        }
                    }
                } else {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(Color.gray.opacity(0.2))
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

struct VerticalSummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.footnote) // subheadlineからfootnoteに変更してより小さく
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.callout) // title3からcalloutに変更してより小さく
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12) // 16から12に減少
        .padding(.vertical, 8) // 12から8に減少
        .background(
            RoundedRectangle(cornerRadius: 10) // 12から10に減少
                .fill(Color(.systemBackground))
                .shadow(radius: 1) // 2から1に減少してより軽い見た目に
        )
    }
}
