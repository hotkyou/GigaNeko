import SwiftUI
import Foundation
import Charts

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

// MARK: - データポイント構造体
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
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    timeSelectionView
                    statisticsCardsView
                    chartView
                }
            }
            .navigationTitle("データ使用量統計")
        }
        .onAppear { saveDataUsage() }
    }
    
    // MARK: - Subviews
    private var timeSelectionView: some View {
        VStack {
            Picker("期間", selection: $selectedSegment) {
                ForEach(TimeSegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
            dateNavigationView
        }
        .padding(.horizontal)
    }
    
    private var dateNavigationView: some View {
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
    
    private var statisticsCardsView: some View {
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
    }
    
    private var chartView: some View {
        VStack(alignment: .leading) {
            Text("使用量推移")
                .font(.headline)
                .padding(.leading)
            
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
                "WiFi": .blue,
                "モバイル": .orange
            ])
            .chartXScale(domain: getChartDateRange())
            .chartYScale(domain: 0...(statistics.maxTotal * 1.2))
            .chartXAxis(content: customXAxis)
            .chartYAxis(content: customYAxis)
            .chartXSelection(value: $rawSelectedDate)
            .frame(height: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 2)
            )
            
            legendView
        }
        .padding()
    }
    
    private var legendView: some View {
        HStack {
            Label("WiFi", systemImage: "circle.fill")
                .foregroundColor(.blue)
            Spacer()
            Label("モバイル", systemImage: "circle.fill")
                .foregroundColor(.orange)
        }
        .padding(.horizontal)
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
                    Text(date, format: getAxisLabelFormat())
                        .font(.caption)
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
