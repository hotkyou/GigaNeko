import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationSettings: [NotificationType: Bool] = [:]
    @State private var showingPermissionAlert = false
    @State private var targetDataUsage: Double = UserDefaults.shared.double(forKey: "targetDataUsage")
    @State private var scheduledNotifications: [UNNotificationRequest] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("通知の種類")) {
                    ForEach(NotificationType.allCases, id: \.self) { type in
                        notificationToggleRow(for: type)
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
