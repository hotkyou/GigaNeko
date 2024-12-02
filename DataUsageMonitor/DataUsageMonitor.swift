import WidgetKit
import SwiftUI
import Charts

struct DataEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let wifi: Double
    let wwan: Double
    let dataLimit: Int
    
    var total: Double { wifi + wwan }
    var remainingData: Double { max(0, Double(dataLimit) - wwan) }
    
    init(date: Date, configuration: ConfigurationAppIntent, wifi: Double, wwan: Double) {
        self.date = date
        self.configuration = configuration
        self.wifi = wifi
        self.wwan = wwan
        self.dataLimit = UserDefaults.shared.integer(forKey: "dataNumber") == 0 ? 7 : UserDefaults.shared.integer(forKey: "dataNumber")
    }
}

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> DataEntry {
        DataEntry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            wifi: 2.5,
            wwan: 1.8
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> DataEntry {
        // 現在の月のデータを取得
        let (wifi, wwan) = getCurrentMonthUsage()
        
        return DataEntry(
            date: Date(),
            configuration: configuration,
            wifi: wifi,
            wwan: wwan
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<DataEntry> {
        
        // データの更新
        saveDataUsage()
        // 現在の月のデータを取得
        let (wifi, wwan) = getCurrentMonthUsage()
        
        let entry = DataEntry(
            date: Date(),
            configuration: configuration,
            wifi: wifi,
            wwan: wwan
        )
        
        // 30分ごとに更新
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func bytesToGB(_ bytes: Int64) -> Double {
        Double(bytes) / (1024 * 1024 * 1024)
    }

    private func getCurrentMonthUsage() -> (wifi: Double, wwan: Double) {
        let calendar = Calendar.current
        let currentDate = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) else {
            return (0, 0)
        }
        
        // 月間データを取得
        let monthlyData = loadMonthlyDataUsage(for: startOfMonth)
        
        // WiFiの合計を計算
        let totalWifi = monthlyData.reduce(0.0) { sum, data in
            sum + (Double(data.wifi) / (1024 * 1024 * 1024))
        }
        
        // モバイルデータの合計を計算
        let totalWwan = monthlyData.reduce(0.0) { sum, data in
            sum + (Double(data.wwan) / (1024 * 1024 * 1024))
        }
        
        return (totalWifi, totalWwan)
    }
}

struct DataUsageMonitorEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

struct SmallWidgetView: View {
    let entry: DataEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // ヘッダー
            HStack {
                Text("今月の通信量")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            Spacer()
            
            // 使用量とデータ制限
            VStack(spacing: 6) {
                // 使用量
                HStack {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .foregroundColor(.orange)
                    Text(String(format: "%.1f GB / %d GB", entry.wwan, entry.dataLimit))
                        .font(.caption2)
                    Spacer()
                }
                
                // プログレスバー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景のバー
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // 使用量のバー
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: min(CGFloat(entry.wwan / Double(entry.dataLimit)) * geometry.size.width, geometry.size.width), height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
                
                // 残り通信量
                HStack {
                    Image(systemName: "gauge.with.dots.needle.50percent")
                        .foregroundColor(.green)
                    Text(String(format: "残り %.1f GB", entry.remainingData))
                        .font(.caption2)
                    Spacer()
                }
            }
            
            Spacer()
            
            // 更新日時
            HStack {
                Text(entry.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    let entry: DataEntry
    
    var body: some View {
        HStack {
            // 使用量情報
            VStack(alignment: .leading, spacing: 8) {
                Text("今月の通信量")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    // 合計データ制限
                    Text(String(format: "%d GB プラン", entry.dataLimit))
                        .font(.headline)
                    
                    // 使用量
                    Text(String(format: "使用量: %.1f GB", entry.wwan))
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    // 残り通信量
                    Text(String(format: "残り: %.1f GB", entry.remainingData))
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // 更新日時
                Text(entry.date, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 円グラフ
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(entry.wwan / Double(entry.dataLimit), 1.0)))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.1f%%", (entry.wwan / Double(entry.dataLimit)) * 100))
                        .font(.system(size: 16, weight: .bold))
                    Text("使用")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
        }
        .padding()
    }
}

struct CircularLockScreenView: View {
    let entry: DataEntry
    
    var body: some View {
        Gauge(value: entry.wwan, in: 0...Double(entry.dataLimit)) {
            Image(systemName: "antenna.radiowaves.left.and.right")
        } currentValueLabel: {
            Text(String(format: "%.1f", entry.wwan))
                .font(.system(size: 12, weight: .medium))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct RectangularLockScreenView: View {
    let entry: DataEntry
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Text("モバイル通信")
                    .font(.system(size: 12, weight: .medium))
            }
            .foregroundColor(.orange)
            
            HStack {
                Text(String(format: "%.1f GB / %d GB", entry.wwan, entry.dataLimit))
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text(String(format: "残り %.1f GB", entry.remainingData))
                    .font(.system(size: 12))
                    .foregroundColor(.green)
            }
        }
    }
}

struct InlineLockScreenView: View {
    let entry: DataEntry
    
    var body: some View {
        Text(String(format: "通信量: %.1f GB / %d GB", entry.wwan, entry.dataLimit))
    }
}

struct DataUsageMonitor: Widget {
    let kind: String = "DataUsageMonitor"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            DataUsageMonitorEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,    // ロック画面の円形ウィジェット
            .accessoryRectangular, // ロック画面の長方形ウィジェット
            .accessoryInline       // ロック画面のインラインウィジェット
        ])
        .configurationDisplayName("データ使用量")
        .description("月間のデータ使用量と残量を表示")
    }
}
