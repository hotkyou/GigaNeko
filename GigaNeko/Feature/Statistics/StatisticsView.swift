import SwiftUI

struct StatisticsView: View {
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

    var body: some View {
        ZStack {
            backgroundImage
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    tabBar
                    VStack(spacing: 20) {
                        TimeSegmentControl(selectedSegment: $selectedSegment, selectedTab: selectedTab)
                        DateNavigationBar(currentDate: currentDate, selectedSegment: selectedSegment, selectedTab: selectedTab, onDateChange: moveDate)
                        NetworkUsageChartCard(chart: NetworkUsageChart(displayData: displayData, predictionData: predictionData, showLowConfidenceWarning: showLowConfidenceWarning, selectedTab: selectedTab, selectedSegment: selectedSegment, currentDate: currentDate, selectedDataPoint: $selectedDataPoint, isDragging: $isDragging, selectedLocation: $selectedLocation), color: currentColor)
                        summarySectionView
                    }
                }
                .frame(maxWidth: 500)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: MobilePlansView()) {
                    HStack(spacing: 3) {
                        Image(systemName: "yensign.circle.fill")
                            .imageScale(.medium)
                        Text("プラン")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 5)
                    .background(
                        currentColor.gradient
                            .opacity(0.9)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                    )
                    .shadow(color: currentColor.opacity(0.2), radius: 3, x: 0, y: 2)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear { updatePredictions() }
        .onChange(of: selectedSegment) { updatePredictions() }
    }

    private var backgroundImage: some View {
        Image("nikukyu")
            .resizable()
            .renderingMode(.template)
            .foregroundStyle(currentColor.opacity(0.1))
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
    }

    private var tabBar: some View {
        HStack(spacing: 16) {
            Spacer(minLength: 0)
            TabButton(title: "モバイル", isSelected: selectedTab == "モバイル", color: .orange) {
                withAnimation { selectedTab = "モバイル" }
            }
            TabButton(title: "WiFi", isSelected: selectedTab == "WiFi", color: .green) {
                withAnimation { selectedTab = "WiFi" }
            }
            Spacer(minLength: 0)
        }
    }

    private var summarySectionView: some View {
        VStack(spacing: 16) {
            Text(monthTitle)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(currentColor)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 12) {
                if selectedTab == "モバイル" {
                    SummaryCard(title: "使った通信量", value: String(format: "%.1f GB", monthlyStatistics.totalWwan), color: .orange)
                    SummaryCard(title: "残っている通信量", value: String(format: "%.1f GB", max(0, Double(dataLimit) - monthlyStatistics.totalWwan)), color: .orange)
                    SummaryCard(title: "月間制限", value: "\(dataLimit) GB", color: .orange)
                } else {
                    SummaryCard(title: "今月の使用量", value: String(format: "%.1f GB", monthlyStatistics.totalWifi), color: .green)
                    SummaryCard(title: "1日平均", value: String(format: "%.1f GB", monthlyStatistics.totalWifi / 30), color: .green)
                    SummaryCard(title: "最大使用日", value: String(format: "%.1f GB", monthlyStatistics.maxTotal), color: .green)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter.string(from: currentDate) + "の使用状況"
    }

    private var currentColor: Color {
        selectedTab == "モバイル" ? .orange : .green
    }

    private func moveDate(by value: Int) {
        if let newDate = calendar.date(byAdding: selectedSegment.calendarComponent, value: value, to: currentDate) {
            currentDate = newDate
        }
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
    
    private var displayData: [DataPoint] {
        switch selectedSegment {
        case .daily: return loadHourlyData()
        case .weekly: return loadWeeklyData()
        case .monthly: return loadMonthlyData()
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
}

extension Calendar {
    func startOfDay(for date: Date) -> Date {
        return self.date(bySettingHour: 0, minute: 0, second: 0, of: date) ?? date
    }
    
    func endOfDay(for date: Date) -> Date {
        return self.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
    }
}
