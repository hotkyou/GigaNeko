import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationSettings: [NotificationType: Bool] = [:]
    @State private var dailyReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()
    @State private var weeklyReportTime: Date = Calendar.current.date(from: DateComponents(hour: 18)) ?? Date()
    @State private var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @State private var showingPermissionAlert = false
    @State private var targetDataUsage: Double = UserDefaults.shared.double(forKey: "targetDataUsage")
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    
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
                Section(header: Text("スケジュールされた通知")) {
                    ForEach(scheduledNotifications, id: \.identifier) { request in
                        VStack(alignment: .leading) {
                            Text(request.content.title)
                                .font(.headline)
                            Text(request.content.body)
                                .font(.subheadline)
                            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                               let nextTriggerDate = trigger.nextTriggerDate() {
                                Text("次回: \(nextTriggerDate, formatter: DateFormatter.shortDateTime)")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .navigationTitle("通知設定")
        }
        .onAppear {
            loadCurrentSettingsFromUserDefaults()
            loadScheduledNotifications()
        }
        .alert("通知権限が必要です", isPresented: $showingPermissionAlert) {
            Button("設定を開く") { openSettings() }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("通知を受け取るには、設定アプリから権限を許可してください。")
        }
    }
    
    private func loadScheduledNotifications() {
        NotificationScheduler.nshared.getScheduledNotifications { notifications in
            self.scheduledNotifications = notifications
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
    
    private func loadCurrentSettingsFromUserDefaults() {
        NotificationType.allCases.forEach { type in
            let key = "notification_\(type.rawValue)_enabled"
            notificationSettings[type] = UserDefaults.shared.bool(forKey: key)
        }
        
        dailyReminderTime = UserDefaults.shared.object(forKey: "dailyReminderTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 20)) ?? Date()
        weeklyReportTime = UserDefaults.shared.object(forKey: "weeklyReportTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 18)) ?? Date()
        selectedWeekday = UserDefaults.shared.integer(forKey: "weeklyReportWeekday")
        targetDataUsage = UserDefaults.shared.double(forKey: "targetDataUsage")
    }
    
    private func saveAndUpdateNotificationType(_ type: NotificationType, enabled: Bool) {
        let key = "notification_\(type.rawValue)_enabled"
        UserDefaults.shared.set(enabled, forKey: key)
        NotificationScheduler.nshared.toggleNotificationType(type, enabled: enabled)
        NotificationScheduler.nshared.rescheduleAllNotifications()
        loadScheduledNotifications()
        print("nt")
    }
    
    private func saveAndUpdateDailyReminder(_ time: Date) {
        UserDefaults.shared.set(time, forKey: "dailyReminderTime")
        NotificationScheduler.nshared.toggleNotificationType(.dailyReminder, enabled: true)
        NotificationScheduler.nshared.rescheduleAllNotifications()
        loadScheduledNotifications()
        print("dr")
    }
    
    private func saveAndUpdateWeeklyReport(time: Date? = nil, weekday: Int? = nil) {
        if let time = time {
            UserDefaults.shared.set(time, forKey: "weeklyReportTime")
        }
        if let weekday = weekday {
            UserDefaults.shared.set(weekday, forKey: "weeklyReportWeekday")
        }
        NotificationScheduler.nshared.toggleNotificationType(.weeklyReport, enabled: true)
        NotificationScheduler.nshared.rescheduleAllNotifications()
        loadScheduledNotifications()
        print("wr")
    }
    
    private func saveAndUpdateDataUsage(_ value: Double) {
        UserDefaults.shared.set(value, forKey: "targetDataUsage")
        NotificationScheduler.nshared.updateDataUsageNotification()
        NotificationScheduler.nshared.rescheduleAllNotifications()
        loadScheduledNotifications()
        print("du")
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

extension DateFormatter {
    static let shortDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}
