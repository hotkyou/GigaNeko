import SwiftUI
import Charts

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
