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
    @State private var currentDate = Date()
    @State private var selectedDataPoint: DataPoint?
    @State private var selectedLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    
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
        var relevantData: [DataPoint]
        switch selectedSegment {
        case .daily:
            relevantData = loadHourlyData()
        case .weekly:
            relevantData = loadWeeklyData()
        case .monthly:
            relevantData = loadMonthlyData()
        }
        
        let totalWifi = relevantData.reduce(0) { $0 + $1.wifi }
        let totalWwan = relevantData.reduce(0) { $0 + $1.wwan }
        let maxTotal = relevantData.map(\.total).max() ?? 0
        
        return (totalWifi, totalWwan, maxTotal)
    }
    
    private var monthlyStatistics: (totalWifi: Double, totalWwan: Double, maxTotal: Double) {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return (0, 0, 0)
        }
        
        let monthlyData = loadMonthlyDataUsage(for: startOfMonth)
        
        let totalWifi = monthlyData.reduce(0) { $0 + Double($1.wifi) / 1024 / 1024 / 1024 }
        let totalWwan = monthlyData.reduce(0) { $0 + Double($1.wwan) / 1024 / 1024 / 1024 }
        let maxTotal = monthlyData.map { Double($0.wifi + $0.wwan) / 1024 / 1024 / 1024 }.max() ?? 0
        
        return (totalWifi, totalWwan, maxTotal)
    }
    
    private let selectionColors = (
        ruleLine: Color.orange.opacity(0.3),
        background: Color(.systemGray6).opacity(0.95),
        border: Color.orange.opacity(0.3)
    )

    // MARK: - Body
    var body: some View {
        ZStack {
            Image("StaticBackGround")
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack(spacing: 20) {
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
                    VStack(spacing: 8) {
                        // グラフのヘッダー
                        HStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.3))
                                .frame(width: 5, height: 18)
                            
                            Text("データ使用量")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 5)
                                .background(Color.orange.opacity(0.3))
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 30)
                        
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
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(15)
                        
                        // グラフ部分
                        ZStack(alignment: .top) {
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
                                
                                if let selectedPoint = selectedDataPoint {
                                    RuleMark(x: .value("Selected", selectedPoint.date))
                                        .foregroundStyle(selectionColors.ruleLine)
                                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                                    
                                    PointMark(
                                        x: .value("Date", selectedPoint.date),
                                        y: .value("WiFi", selectedPoint.wifi)
                                    )
                                    .foregroundStyle(Color.green)
                                    .symbolSize(80)
                                    
                                    PointMark(
                                        x: .value("Date", selectedPoint.date),
                                        y: .value("Mobile", selectedPoint.wwan)
                                    )
                                    .foregroundStyle(Color.orange)
                                    .symbolSize(80)
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
                            .chartOverlay { proxy in
                                GeometryReader { geometry in
                                    Rectangle()
                                        .fill(.clear)
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    if !isDragging {
                                                        isDragging = true
                                                    }
                                                    let adjustedLocation = CGPoint(
                                                        x: value.location.x - geometry.frame(in: .local).minX,
                                                        y: value.location.y - geometry.frame(in: .local).minY
                                                    )
                                                    selectedLocation = adjustedLocation
                                                    updateSelectedDataPoint(at: geometry, proxy: proxy)
                                                }
                                                .onEnded { _ in
                                                    isDragging = false
                                                    selectedDataPoint = nil
                                                }
                                        )
                                }
                            }
                            
                            if let selected = selectedDataPoint {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(selected.date))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 8) {
                                        SelectionDataLabel(
                                            iconName: "wifi",
                                            value: selected.wifi,
                                            color: .green
                                        )
                                        
                                        SelectionDataLabel(
                                            iconName: "antenna.radiowaves.left.and.right",
                                            value: selected.wwan,
                                            color: .orange
                                        )
                                        
                                        SelectionDataLabel(
                                            iconName: "sum",
                                            value: selected.total,
                                            color: .primary
                                        )
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(selectionColors.background)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(selectionColors.border, lineWidth: 1)
                                        )
                                )
                                .padding(.top, 8)
                                .transition(.opacity)
                            }
                        }
                        .frame(height: 200)
                        .padding(6)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                        
                        // 使用量サマリー
                        VStack(spacing: 4) {
                            HStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 5, height: 18)
                                
                                Text(monthTitle)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 3)
                                    .background(Color.orange.opacity(0.3))
                                    .cornerRadius(10)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 12)
                            
                            VStack(spacing: 4) {
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
                            .padding(.horizontal, 12)
                        }
                        .padding(6)
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
        }.toolbar(.hidden, for: .tabBar)
    }
    
    // MARK: - Helper Methods
    private func updateSelectedDataPoint(at geometry: GeometryProxy, proxy: ChartProxy) {
            // プロキシの座標空間内でX位置を計算
        let xPosition = selectedLocation.x
        
        guard let date = proxy.value(atX: xPosition, as: Date.self) else { return }
        
        // 最も近いデータポイントを見つける
        var closestPoint: DataPoint?
        var minDistance: TimeInterval = .infinity
        
        for point in displayData {
            let distance = abs(point.date.timeIntervalSince(date))
            if distance < minDistance {
                minDistance = distance
                closestPoint = point
            }
        }
        
        // 選択されたデータポイントを更新
        if isDragging {
            selectedDataPoint = closestPoint
        }
    }
    
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
    
    private func moveDate(by value: Int) {
        if let newDate = calendar.date(byAdding: selectedSegment.calendarComponent, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func getChartDateRange() -> ClosedRange<Date> {
        switch selectedSegment {
        case .daily:
            let startDate = calendar.startOfDay(for: currentDate)
            guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
                return startDate...startDate
            }
            return startDate...endDate
            
        case .weekly:
            let startDate = weekStartDate
            guard let endDate = calendar.date(byAdding: .day, value: 6, to: startDate) else {
                return startDate...startDate
            }
            guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endDate) else {
                return startDate...startDate
            }
            return startDate...endOfDay
            
        case .monthly:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
                return currentDate...currentDate
            }
            guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                return startOfMonth...startOfMonth
            }
            guard let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth) else {
                return startOfMonth...startOfMonth
            }
            return startOfMonth...endOfDay
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        switch selectedSegment {
        case .daily:
            formatter.dateFormat = "H時"
        case .weekly:
            formatter.dateFormat = "M/d (E)"
            formatter.locale = Locale(identifier: "ja_JP")
        case .monthly:
            formatter.dateFormat = "M/d"
        }
        return formatter.string(from: date)
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
                        
                        if day >= 30 {
                            return isLastDayOfMonth
                        }
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
}

// MARK: - Supporting Views
struct SelectionDataLabel: View {
    let iconName: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: iconName)
                .font(.system(size: 12))
                .foregroundColor(color)
            
            Text(String(format: "%.1fGB", value))
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(color)
        }
        .frame(minWidth: 50, alignment: .leading)
    }
}

// DataLabelコンポーネントの更新（グラフ凡例用）
struct DataLabel: View {
    let title: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundColor(color.opacity(0.8))
            Text(String(format: "%.2f GB", value))
                .font(.caption)
                .foregroundColor(color)
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
                .font(.footnote)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.callout)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(radius: 1)
        )
    }
}
