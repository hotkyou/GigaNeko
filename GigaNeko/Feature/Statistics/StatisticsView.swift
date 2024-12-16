import SwiftUI
import Charts
import Foundation

// MARK: - Base Types
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

// MARK: - Main View
struct StatisticsView: View {
    // MARK: - Properties
    @State private var selectedSegment: TimeSegment = .daily
    @State private var selectedTab: String = "モバイル"
    @State private var currentDate = Date()
    @State private var selectedDataPoint: DataPoint?
    @State private var selectedLocation: CGPoint = .zero
    @State private var isDragging: Bool = false
    @State private var dataLimit: Int = UserDefaults.shared.integer(forKey: "dataNumber")
    @State private var predictionData: [DataPoint] = []
    @State private var showLowConfidenceWarning = false
    private let predictor = DataUsagePredictor.shared
    
    private let calendar = Calendar.current
    
    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: currentDate) + "の使用状況"
    }
    
    private func updatePredictions() {
        if selectedSegment == .monthly {
            if let prediction = predictor.predictEndOfMonth() {
                showLowConfidenceWarning = prediction.confidence < 0.6
                
                var predictionPoints: [DataPoint] = []
                
                if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                   let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) {
                    
                    let today = Date()
                    
                    // 実績データの最後の値を取得（スタート地点として使用）
                    let lastActualData = displayData.last ?? DataPoint(date: today, wifi: 0, wwan: 0)
                    
                    let daysRemaining = calendar.dateComponents([.day], from: today, to: endOfMonth).day ?? 0
                    guard daysRemaining > 0 else { return }
                    
                    // 1日あたりの予測増加量を計算
                    let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
                    let dailyWifiIncrease = prediction.predictedWifi / Double(daysInMonth)
                    let dailyWwanIncrease = prediction.predictedWwan / Double(daysInMonth)
                    
                    // 実績値からスタート
                    var accumulatedWifi = lastActualData.wifi
                    var accumulatedWwan = lastActualData.wwan
                    var currentDate = today
                    
                    // 今日のデータポイントを追加（実績とのつながりを表現）
                    predictionPoints.append(DataPoint(
                        date: today,
                        wifi: accumulatedWifi,
                        wwan: accumulatedWwan
                    ))
                    
                    // 翌日から予測開始
                    if let nextDay = calendar.date(byAdding: .day, value: 1, to: today) {
                        currentDate = nextDay
                    }
                    
                    while currentDate <= endOfMonth {
                        // 累積値を更新
                        accumulatedWifi += dailyWifiIncrease
                        accumulatedWwan += dailyWwanIncrease
                        
                        predictionPoints.append(DataPoint(
                            date: currentDate,
                            wifi: accumulatedWifi,
                            wwan: accumulatedWwan
                        ))
                        
                        if let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) {
                            currentDate = nextDate
                        } else {
                            break
                        }
                    }
                }
                
                predictionData = predictionPoints
            }
        } else {
            predictionData = []
            showLowConfidenceWarning = false
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景画像
            Image("nikukyu")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(currentColor.opacity(0.1))
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // タブバー
                    HStack(spacing: 16) {
                        Spacer(minLength: 0)
                        TabButton(
                            title: "モバイル",
                            isSelected: selectedTab == "モバイル",
                            color: .orange
                        ) {
                            withAnimation {
                                selectedTab = "モバイル"
                            }
                        }
                        
                        TabButton(
                            title: "WiFi",
                            isSelected: selectedTab == "WiFi",
                            color: .green
                        ) {
                            withAnimation {
                                selectedTab = "WiFi"
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    
                    VStack(spacing: 20) {
                        // 期間選択
                        TimeSegmentControl(
                            selectedSegment: $selectedSegment,
                            selectedTab: selectedTab
                        )
                        
                        // 日付ナビゲーション
                        DateNavigationBar(
                            currentDate: currentDate,
                            selectedSegment: selectedSegment,
                            selectedTab: selectedTab,
                            onDateChange: moveDate
                        )
                        
                        // チャート
                        NetworkUsageChartCard(
                            chart: NetworkUsageChart(
                                displayData: displayData,
                                predictionData: predictionData,
                                showLowConfidenceWarning: showLowConfidenceWarning,
                                selectedTab: selectedTab,
                                selectedSegment: selectedSegment,
                                currentDate: currentDate,
                                selectedDataPoint: $selectedDataPoint,
                                isDragging: $isDragging,
                                selectedLocation: $selectedLocation
                            ),
                            color: currentColor
                        )
                        
                        // サマリーセクション
                        VStack(spacing: 16) {
                            Text(monthTitle)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(currentColor)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            VStack(spacing: 12) {
                                if selectedTab == "モバイル" {
                                    SummaryCard(
                                        title: "使った通信量",
                                        value: String(format: "%.1f GB", monthlyStatistics.totalWwan),
                                        color: .orange
                                    )
                                    
                                    SummaryCard(
                                        title: "残っている通信量",
                                        value: String(format: "%.1f GB", max(0, Double(dataLimit) - monthlyStatistics.totalWwan)),
                                        color: .orange
                                    )
                                    
                                    SummaryCard(
                                        title: "月間制限",
                                        value: "\(dataLimit) GB",
                                        color: .orange
                                    )
                                } else {
                                    SummaryCard(
                                        title: "今月の使用量",
                                        value: String(format: "%.1f GB", monthlyStatistics.totalWifi),
                                        color: .green
                                    )
                                    
                                    SummaryCard(
                                        title: "1日平均",
                                        value: String(format: "%.1f GB", monthlyStatistics.totalWifi / 30),
                                        color: .green
                                    )
                                    
                                    SummaryCard(
                                        title: "最大使用日",
                                        value: String(format: "%.1f GB", monthlyStatistics.maxTotal),
                                        color: .green
                                    )
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            updatePredictions()
        }
        .onChange(of: selectedSegment) { _ in
            updatePredictions()
        }
    }

    private var currentColor: Color {
        selectedTab == "モバイル" ? .orange : .green
    }
    
    // MARK: - Helper Methods
    private func moveDate(by value: Int) {
        if let newDate = calendar.date(byAdding: selectedSegment.calendarComponent, value: value, to: currentDate) {
            currentDate = newDate
        }
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfDay(for date: Date) -> Date {
        return self.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
    }
    
    func endOfDay(for date: Date) -> Date {
        return self.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }
}

// MARK: - Tab Bar Component
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .bold : .regular))
                .foregroundColor(isSelected ? .white : .gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(isSelected ? color : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Time Segment Control
struct TimeSegmentControl: View {
    @Binding var selectedSegment: TimeSegment
    let selectedTab: String
    
    private var segmentColor: Color {
        selectedTab == "モバイル" ? .orange : .green
    }
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(TimeSegment.allCases, id: \.self) { segment in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedSegment = segment
                    }
                }) {
                    Text(segment.rawValue)
                        .font(.system(size: 14, weight: selectedSegment == segment ? .bold : .regular))
                        .foregroundColor(selectedSegment == segment ? segmentColor : .gray)
                        .frame(minWidth: 50)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selectedSegment == segment {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(segmentColor.opacity(0.15))
                                    
                                    // 下部のアクセントライン
                                    Rectangle()
                                        .fill(segmentColor)
                                        .frame(height: 2)
                                        .offset(y: 12)
                                }
                            }
                        )
                }
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Date Navigation Bar
struct DateNavigationBar: View {
    let currentDate: Date
    let selectedSegment: TimeSegment
    let selectedTab: String
    let onDateChange: (Int) -> Void
    
    private var navigationColor: Color {
        selectedTab == "モバイル" ? .orange : .green
    }
    
    var body: some View {
        HStack {
            Button(action: { onDateChange(-1) }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(navigationColor)
                            .shadow(color: navigationColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
            }
            
            Spacer()
            
            Text(formattedDate)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
            
            Spacer()
            
            Button(action: { onDateChange(1) }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(navigationColor)
                            .shadow(color: navigationColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        switch selectedSegment {
        case .daily:
            formatter.dateFormat = "yyyy年M月d日"
            return formatter.string(from: currentDate)
            
        case .weekly:
            formatter.dateFormat = "yyyy年M月d日"
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) ?? currentDate
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? currentDate
            let endFormatter = DateFormatter()
            endFormatter.dateFormat = "d日"
            return "\(formatter.string(from: weekStart)) - \(endFormatter.string(from: weekEnd))"
            
        case .monthly:
            formatter.dateFormat = "yyyy年M月"
            return formatter.string(from: currentDate)
        }
    }
}

// MARK: - Network Usage Chart
struct NetworkUsageChart: View {
    let displayData: [DataPoint]
    let predictionData: [DataPoint]
    let showLowConfidenceWarning: Bool
    let selectedTab: String
    let selectedSegment: TimeSegment
    let currentDate: Date
    private let predictor = DataUsagePredictor.shared
    @Binding var selectedDataPoint: DataPoint?
    @Binding var isDragging: Bool
    @Binding var selectedLocation: CGPoint
    
    private let calendar = Calendar.current
    
    private var chartColor: Color {
        selectedTab == "モバイル" ? .orange : .green
    }
    
    private var weekStartDate: Date {
        calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) ?? currentDate
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Chart {
                ForEach(displayData) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Usage", selectedTab == "モバイル" ? item.wwan : item.wifi)
                    )
                    .foregroundStyle(by: .value("Type", "実績"))
                    .interpolationMethod(.linear)
                }
                
                if selectedSegment == .monthly {
                    ForEach(predictionData) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Usage", selectedTab == "モバイル" ? item.wwan : item.wifi)
                        )
                        .foregroundStyle(by: .value("Type", "予測"))
                        .interpolationMethod(.linear)
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    }
                }
                
                if let selectedPoint = selectedDataPoint {
                    RuleMark(x: .value("Selected", selectedPoint.date))
                        .foregroundStyle(chartColor.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
                    
                    PointMark(
                        x: .value("Date", selectedPoint.date),
                        y: .value("Usage", selectedTab == "モバイル" ? selectedPoint.wwan : selectedPoint.wifi)
                    )
                    .foregroundStyle(chartColor)
                    .symbolSize(80)
                }
            }
            .chartForegroundStyleScale([
                "実績": chartColor,
                "予測": chartColor.opacity(0.5)
            ])
            .chartXScale(domain: getChartDateRange())
            .chartYScale(domain: 0...getMaxValue())
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
                                    let frame = geometry.frame(in: .local)
                                    let location = CGPoint(
                                        x: value.location.x - frame.minX,
                                        y: value.location.y - frame.minY
                                    )
                                    
                                    // チャートの範囲内かチェック
                                    guard location.x >= 0,
                                          location.x <= frame.width,
                                          location.y >= 0,
                                          location.y <= frame.height,
                                          let date = proxy.value(atX: location.x, as: Date.self) else {
                                        return
                                    }
                                    
                                    if !isDragging {
                                        isDragging = true
                                    }
                                    selectedLocation = location
                                    
                                    // 最も近いデータポイントを見つける
                                    var closestPoint: DataPoint?
                                    var minDistance: TimeInterval = .infinity
                                    
                                    let allData = selectedSegment == .monthly ?
                                        displayData + predictionData : displayData
                                    
                                    for point in allData {
                                        let distance = abs(point.date.timeIntervalSince(date))
                                        if distance < minDistance {
                                            minDistance = distance
                                            closestPoint = point
                                        }
                                    }
                                    
                                    if isDragging {
                                        selectedDataPoint = closestPoint
                                    }
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    selectedDataPoint = nil
                                }
                        )
                }
            }
            
            if showLowConfidenceWarning && selectedSegment == .monthly {
                Text("予測の信頼性が低い可能性があります")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.top, 4)
            }
            
            if let selected = selectedDataPoint {
                let isFromPrediction = selectedSegment == .monthly &&
                    predictionData.contains(where: { $0.date == selected.date })
                
                DataSelectionTooltip(
                    dataPoint: selected,
                    selectedTab: selectedTab,
                    chartColor: chartColor,
                    selectedSegment: selectedSegment,
                    isPrediction: isFromPrediction,
                    predictionDetails: isFromPrediction ? predictor.predictEndOfMonth() : nil
                )
                .padding(.top, 8)
                .transition(.opacity)
            }
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
            return startDate...calendar.endOfDay(for: endDate)
            
        case .monthly:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)),
                  let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
                return currentDate...currentDate
            }
            return startOfMonth...calendar.endOfDay(for: endOfMonth)
        }
    }
    
    private func getMaxValue() -> Double {
        var maxValue: Double = 0
        
        // 実績データの最大値を取得
        let actualMax = displayData.map { selectedTab == "モバイル" ? $0.wwan : $0.wifi }.max() ?? 0
        maxValue = max(maxValue, actualMax)
        
        // 予測データがある場合はその最大値も考慮
        if selectedSegment == .monthly {
            let predictionMax = predictionData.map { selectedTab == "モバイル" ? $0.wwan : $0.wifi }.max() ?? 0
            maxValue = max(maxValue, predictionMax)
        }
        
        return max(0.1, maxValue * 1.2)
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
                        return true // すべての日を表示
                    case .monthly:
                        let day = calendar.component(.day, from: date)
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
}

struct NetworkUsageChartCard: View {
    let chart: NetworkUsageChart
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            chart
                .frame(height: 150)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

extension StatisticsView {
    // MARK: - Data Loading Methods
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
        let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: currentDate)) ?? currentDate
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
        var accumulatedWifi: Double = 0
        var accumulatedWwan: Double = 0
        
        return monthlyData.compactMap { usage -> DataPoint? in
            guard let date = calendar.date(byAdding: .day, value: usage.day - 1, to: startOfMonth) else {
                return nil
            }
            
            // 現在の日付までのデータのみを累積
            if date <= Date() {
                accumulatedWifi += Double(usage.wifi) / 1024 / 1024 / 1024
                accumulatedWwan += Double(usage.wwan) / 1024 / 1024 / 1024
                
                return DataPoint(
                    date: date,
                    wifi: accumulatedWifi,
                    wwan: accumulatedWwan
                )
            }
            
            return nil
        }
    }
    
    // MARK: - Statistics Calculation
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
    
    // MARK: - Date Formatting
    private func formatDate(_ date: Date, for segment: TimeSegment) -> String {
        let formatter = DateFormatter()
        switch segment {
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
}

struct DataSelectionTooltip: View {
    let dataPoint: DataPoint
    let selectedTab: String
    let chartColor: Color
    let selectedSegment: TimeSegment
    let isPrediction: Bool
    let predictionDetails: UsagePredictionResult?
    
    private var usageValue: Double {
        selectedTab == "モバイル" ? dataPoint.wwan : dataPoint.wifi
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ヘッダー部分
            HStack {
                Circle()
                    .fill(chartColor)
                    .frame(width: 8, height: 8)
                
                Text(formatDate(dataPoint.date))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
                
                if isPrediction {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("予測")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(chartColor.opacity(0.7))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(chartColor.opacity(0.1))
                    )
                }
            }
            
            Divider()
                .background(chartColor.opacity(0.3))
            
            // データ表示部分
            VStack(alignment: .leading, spacing: 8) {
                // 現在の使用量
                DataRow(
                    iconName: selectedTab == "モバイル" ? "antenna.radiowaves.left.and.right" : "wifi",
                    label: isPrediction ? "予測使用量" : "使用量",
                    value: usageValue,
                    color: chartColor
                )
                
                // 予測の場合は追加情報を表示
                if isPrediction, let prediction = predictionDetails {
                    VStack(alignment: .leading, spacing: 6) {
                        // 信頼度インジケーター
                        HStack(spacing: 4) {
                            Text("予測の信頼度")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(index < Int(prediction.confidence * 5) ? chartColor : chartColor.opacity(0.2))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        
                        // ピーク時間帯
                        HStack {
                            Text("ピーク時間帯")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            ForEach(prediction.peakHours.prefix(3), id: \.self) { hour in
                                Text("\(hour)時")
                                    .font(.system(size: 11))
                                    .foregroundColor(chartColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(chartColor.opacity(0.1))
                                    )
                            }
                        }
                        
                        // 予測の特徴
                        if prediction.isUnusualPattern {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 11))
                                Text("通常より多い使用量")
                                    .font(.system(size: 11))
                            }
                            .foregroundColor(.orange)
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(chartColor.opacity(0.1))
                    )
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground).opacity(0.95))
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(chartColor.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        
        switch selectedSegment {
        case .daily:
            formatter.dateFormat = "M月d日 H時"
        case .weekly:
            formatter.dateFormat = "M月d日(E)"
        case .monthly:
            formatter.dateFormat = "M月d日"
        }
        return formatter.string(from: date)
    }
}

struct DataRow: View {
    let iconName: String
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack {
            // 左側：アイコンとラベル
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .frame(width: 90, alignment: .leading)
            
            Spacer()
            
            // 右側：使用量
            Text(String(format: "%.2f GB", value))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
    }
}
