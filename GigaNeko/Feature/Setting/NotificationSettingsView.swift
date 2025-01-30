import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationSettings: [NotificationType: Bool] = [:]
    @State private var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()
    @State private var weeklyReportTime: Date = Calendar.current.date(from: DateComponents(hour: 18)) ?? Date()
    @State private var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @State private var showingPermissionAlert = false
    @State private var targetDataUsage: Double = UserDefaults.shared.double(forKey: "targetDataUsage")
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("通知の種類")) {
                    ForEach(NotificationType.allCases, id: \.self) { type in
                        notificationToggleRow(for: type)
                    }
                }
                
                Section(header: Text("リマインダー設定")) {
                    if notificationSettings[.dailyReminder] ?? false {
                        DatePicker(
                            "日次リマインダー時刻",
                            selection: $dailyReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: dailyReminderTime) { oldValue, newValue in
                            saveAndUpdateDailyReminder(newValue)
                        }
                    }
                    
                    if notificationSettings[.weeklyReport] ?? false {
                        DatePicker(
                            "週次レポート時刻",
                            selection: $weeklyReportTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: weeklyReportTime) { oldValue, newValue in
                            saveAndUpdateWeeklyReport(time: newValue)
                        }
                        
                        Picker("週次レポート曜日", selection: $selectedWeekday) {
                            ForEach(1...7, id: \.self) { index in
                                Text(weekdays[index - 1]).tag(index)
                            }
                        }
                        .onChange(of: selectedWeekday) { oldValue, newValue in
                            saveAndUpdateWeeklyReport(weekday: newValue)
                        }
                    }
                }
                
                Section(header: Text("データ使用量設定")) {
                    HStack {
                        Text("目標ギガ数")
                        Spacer()
                        TextField("GB", value: $targetDataUsage, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    .onChange(of: targetDataUsage) { oldValue, newValue in
                        saveAndUpdateDataUsage(newValue)
                    }
                }
                
                Section {
                    Button(action: requestNotificationPermission) {
                        Text("通知権限を確認")
                    }
                }
            }
            .navigationTitle("通知設定")
        }
        .onAppear {
            loadCurrentSettings()
        }
        .alert("通知権限が必要です", isPresented: $showingPermissionAlert) {
            Button("設定を開く") { openSettings() }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("通知を受け取るには、設定アプリから権限を許可してください。")
        }
    }
    
    private func notificationToggleRow(for type: NotificationType) -> some View {
        Toggle(isOn: Binding(
            get: { notificationSettings[type] ?? false },
            set: { newValue in
                notificationSettings[type] = newValue
                saveAndUpdateNotificationType(type, enabled: newValue)
            }
        )) {
            VStack(alignment: .leading) {
                Text(type.content.title)
                    .font(.headline)
                Text(type.content.body)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func loadCurrentSettings() {
        NotificationType.allCases.forEach { type in
            let key = "notification_\(type.rawValue)_enabled"
            notificationSettings[type] = UserDefaults.shared.bool(forKey: key)
        }
        
        if let savedDailyTime = UserDefaults.shared.object(forKey: "dailyReminderTime") as? Date {
            dailyReminderTime = savedDailyTime
        }
        if let savedWeeklyTime = UserDefaults.shared.object(forKey: "weeklyReportTime") as? Date {
            weeklyReportTime = savedWeeklyTime
        }
        if let savedWeekday = UserDefaults.shared.object(forKey: "weeklyReportWeekday") as? Int {
            selectedWeekday = savedWeekday
        }
        targetDataUsage = UserDefaults.shared.double(forKey: "targetDataUsage")
    }
    
    private func saveAndUpdateNotificationType(_ type: NotificationType, enabled: Bool) {
        let key = "notification_\(type.rawValue)_enabled"
        UserDefaults.shared.set(enabled, forKey: key)
        NotificationScheduler.nshared.toggleNotificationType(type, enabled: enabled)
    }
    
    private func saveAndUpdateDailyReminder(_ time: Date) {
        UserDefaults.shared.set(time, forKey: "dailyReminderTime")
        NotificationScheduler.nshared.toggleNotificationType(.dailyReminder, enabled: true)
    }
    
    private func saveAndUpdateWeeklyReport(time: Date? = nil, weekday: Int? = nil) {
        if let time = time {
            UserDefaults.shared.set(time, forKey: "weeklyReportTime")
        }
        if let weekday = weekday {
            UserDefaults.shared.set(weekday, forKey: "weeklyReportWeekday")
        }
        NotificationScheduler.nshared.toggleNotificationType(.weeklyReport, enabled: true)
    }
    
    private func saveAndUpdateDataUsage(_ value: Double) {
        UserDefaults.shared.set(value, forKey: "targetDataUsage")
        NotificationScheduler.nshared.updateDataUsageNotification()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    print("通知が許可されています")
                } else {
                    showingPermissionAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
