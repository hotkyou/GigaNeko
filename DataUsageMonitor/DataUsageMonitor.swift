import WidgetKit
import AppIntents
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

struct SwitchPageIntent: AppIntent {
    static var title: LocalizedStringResource = "Switch Page"
    
    func perform() async throws -> some IntentResult {
        UserDefaults.shared.set(!UserDefaults.shared.bool(forKey: "isWiFiPage"), forKey: "isWiFiPage")
        return .result()
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
        let (wifi, wwan) = getCurrentMonthUsage()
        return DataEntry(
            date: Date(),
            configuration: configuration,
            wifi: wifi,
            wwan: wwan
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<DataEntry> {
        saveDataUsage()
        let (wifi, wwan) = getCurrentMonthUsage()
        
        let entry = DataEntry(
            date: Date(),
            configuration: configuration,
            wifi: wifi,
            wwan: wwan
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func bytesToGB(_ bytes: Int64) -> Double {
        Double(bytes) / (1024 * 1024 * 1024)
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
        case .systemLarge:
            LargeWidgetView(entry: entry)
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var body: some View {
        let isWiFiPage = UserDefaults.shared.bool(forKey: "isWiFiPage")
        
        ZStack {
            if isWiFiPage {
                wifiDataView
            } else {
                mobileDataView
            }
            
            // ページ切り替えボタン
            VStack {
                Spacer()
                Button(intent: SwitchPageIntent()) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(!isWiFiPage ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                        Circle()
                            .fill(isWiFiPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                }
                .padding(.bottom, 4)
            }
        }
    }
    
    private var updateTimeView: some View {
        HStack {
            Text("更新: \(dateFormatter.string(from: entry.date))")
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // モバイルデータビュー
    private var mobileDataView: some View {
        VStack(spacing: 8) {
            // ヘッダー
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                    .font(.system(size: 12))
                    .foregroundColor(.orange)
                Text("モバイル通信")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            // 使用量とデータ制限
            VStack(spacing: 6) {
                Text(String(format: "%.1f", entry.wwan))
                    .font(.system(size: 28, weight: .medium))
                    + Text(" GB").font(.system(size: 14))
                
                // プログレスバー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 5)
                            .cornerRadius(2.5)
                        
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: min(CGFloat(entry.wwan / Double(entry.dataLimit)) * geometry.size.width, geometry.size.width), height: 5)
                            .cornerRadius(2.5)
                    }
                }
                .frame(height: 5)
                
                // 残り通信量とプラン
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "gauge.with.dots.needle.50percent")
                            .font(.system(size: 11))
                            .foregroundColor(.green)
                        Text(String(format: "残り %.1f GB", entry.remainingData))
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // 更新日時
            updateTimeView
        }
        .padding(10)
    }
    
    // WiFiデータビュー
    private var wifiDataView: some View {
        VStack(spacing: 8) {
            // ヘッダー
            HStack {
                Image(systemName: "wifi")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                Text("WiFi通信量")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            VStack(spacing: 8) {
                Text(String(format: "%.1f", entry.wifi))
                    .font(.system(size: 28, weight: .medium))
                    + Text(" GB").font(.system(size: 14))
            }
            
            Spacer()
            
            // 更新日時
            updateTimeView
        }
        .padding(10)
    }
}

struct MediumWidgetView: View {
    let entry: DataEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
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
                Text("更新: \(dateFormatter.string(from: entry.date))")
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

struct LargeWidgetView: View {
    let entry: DataEntry
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // ヘッダー
            HStack {
                Text("今月のデータ使用状況")
                    .font(.headline)
                Spacer()
                Text("更新: \(dateFormatter.string(from: entry.date))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // データ使用量の詳細情報
            HStack(spacing: 20) {
                // モバイルデータの円グラフ
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(min(entry.wwan / Double(entry.dataLimit), 1.0)))
                            .stroke(Color.orange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        VStack {
                            Text(String(format: "%.1f%%", (entry.wwan / Double(entry.dataLimit)) * 100))
                                .font(.system(size: 20, weight: .bold))
                            Text("使用済")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(width: 120, height: 120)
                    
                    Text("モバイルデータ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                
                // WiFiデータの情報
                VStack(alignment: .leading, spacing: 12) {
                    // WiFi使用量
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "wifi")
                                .foregroundColor(.blue)
                            Text("WiFi通信量")
                                .font(.caption)
                        }
                        Text(String(format: "%.1f GB", entry.wifi))
                            .font(.title3)
                            .bold()
                    }
                    
                    // モバイルデータ詳細
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .foregroundColor(.orange)
                            Text("モバイルデータ")
                                .font(.caption)
                        }
                        Text(String(format: "%.1f GB / %d GB", entry.wwan, entry.dataLimit))
                            .font(.title3)
                            .bold()
                    }
                }
            }
            .padding(.vertical, 8)
            
            // 残りデータ量のプログレスバー
            VStack(alignment: .leading, spacing: 8) {
                Text("残りデータ量")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景のバー
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        // 使用量のバー
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: min(CGFloat(entry.wwan / Double(entry.dataLimit)) * geometry.size.width, geometry.size.width), height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Text(String(format: "残り %.1f GB", entry.remainingData))
                        .font(.callout)
                        .foregroundColor(.green)
                    Spacer()
                    Text(String(format: "合計 %d GB", entry.dataLimit))
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
            
            // 合計使用量
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("合計通信量")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f GB", entry.total))
                        .font(.title2)
                        .bold()
                }
                Spacer()
            }
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "antenna.radiowaves.left.and.right")
                Text("モバイル通信")
                    .font(.system(size: 12, weight: .medium))
                Spacer()
                Text(dateFormatter.string(from: entry.date))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    var body: some View {
        Text(String(format: "通信量: %.1f/%dGB (%@)", entry.wwan, entry.dataLimit, dateFormatter.string(from: entry.date)))
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
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        .configurationDisplayName("データ使用量")
        .description("月間のデータ使用量と残量を表示")
    }
}
