import SwiftUI

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
