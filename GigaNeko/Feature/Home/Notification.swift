import SwiftUI
import UserNotifications

// MARK: - NotificationType Definition
enum NotificationType: String, CaseIterable {
    case stamina = "stamina"           // スタミナ回復通知
    case stress = "stress"             // ストレス警告通知
    case gigaLimit = "gigaLimit"       // データ使用量限界通知
    
    var content: (title: String, body: String) {
        switch self {
        case .stamina:
            return ("餌がなくなりました", "猫がお腹を空かせて待っています！")
        case .stress:
            return ("ストレスが限界です", "猫の機嫌が悪くなっています。癒してあげましょう！")
        case .gigaLimit:
            return ("目標ギガ数に達しました", "データ使用量が制限に近づいています。確認してください。")
        }
    }
}

extension NotificationScheduler {
    func getScheduledNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
}

class NotificationScheduler {
    static let nshared = NotificationScheduler()
    private var periodicCheckTask: DispatchWorkItem?
    private var isRunning = false
    
    private let checkInterval: TimeInterval = 3600 // 1時間
    private let calendar = Calendar.current
    
    func checkAndScheduleNotifications() {
        let checker = NotificationConditionChecker()
        
        NotificationType.allCases.forEach { type in
            if UserDefaults.shared.bool(forKey: "notification_\(type.rawValue)_enabled") {
                if checker.shouldNotify(for: type) && canSendNotification(for: type) {
                    scheduleNotification(for: type)
                }
            }
        }
    }
    
    // MARK: - Notification Condition Checker
    private struct NotificationConditionChecker {
        let giganeko: GiganekoPoint
        let dataLimit: Int
        let currentUsage: Double
        var targetDataUsage: Double
        
        init(giganeko: GiganekoPoint = .shared) {
            self.giganeko = giganeko
            self.dataLimit = UserDefaults.shared.integer(forKey: "dataNumber")
            let (_, wwan) = getCurrentMonthUsage()
            self.currentUsage = wwan
            self.targetDataUsage = UserDefaults.shared.double(forKey: "targetDataUsage")
        }
        
        func shouldNotify(for type: NotificationType) -> Bool {
            // 最後の通知時刻をチェック
            if let lastNotification = UserDefaults.shared.object(forKey: "lastNotificationTime_\(type.rawValue)") as? Date {
                // 同じ日に既に通知を送信している場合は false を返す
                if Calendar.current.isDate(lastNotification, inSameDayAs: Date()) {
                    return false
                }
            }
            
            // 各タイプの条件チェック
            switch type {
            case .stamina:
                return giganeko.stamina <= 1
            case .stress:
                return giganeko.stress >= 80
            case .gigaLimit:
                return (Double(dataLimit) - currentUsage) <= targetDataUsage
            }
        }
    }
    
    // MARK: - Public Methods
    func startScheduling() {
        guard !isRunning else { return }
        isRunning = true

        loadCurrentSettings()
        scheduleAllNotifications()
        startPeriodicCheck()
        print("通知スケジュールスタート")
    }
    
    func rescheduleAllNotifications() {
        cancelAllScheduledTasks()
        loadCurrentSettings()
        scheduleAllNotifications()
    }
    
    func updateDataUsageNotification() {
        let checker = NotificationConditionChecker()
        if checker.shouldNotify(for: .gigaLimit) {
            scheduleNotification(for: .gigaLimit)
        } else {
            removeNotifications(for: .gigaLimit)
        }
    }
    
    func toggleNotificationType(_ type: NotificationType, enabled: Bool) {
        let key = "notification_\(type.rawValue)_enabled"
        UserDefaults.shared.set(enabled, forKey: key)
        
        if enabled {
            let checker = NotificationConditionChecker()
            if checker.shouldNotify(for: type) {
                scheduleNotification(for: type)
            }
        } else {
            removeNotifications(for: type)
        }
    }
    
    func saveNotificationSettings() {
        NotificationType.allCases.forEach { type in
            let key = "notification_\(type.rawValue)_enabled"
            if UserDefaults.shared.bool(forKey: key) {
                let checker = NotificationConditionChecker()
                if checker.shouldNotify(for: type) {
                    scheduleNotification(for: type)
                }
            }
        }
    }
    
    func cancelAllScheduledTasks() {
        stopPeriodicCheck()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isRunning = false
    }
    
    // MARK: - Private Methods
    private func startPeriodicCheck() {
        stopPeriodicCheck()
        
        let task = DispatchWorkItem { [weak self] in
            self?.checkAndUpdateNotifications()
            self?.startPeriodicCheck()
        }
        
        periodicCheckTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + checkInterval, execute: task)
    }
    
    private func stopPeriodicCheck() {
        periodicCheckTask?.cancel()
        periodicCheckTask = nil
    }
    
    private func loadCurrentSettings() {
        NotificationType.allCases.forEach { type in
            let key = "notification_\(type.rawValue)_enabled"
            // デフォルトを true に設定
            if UserDefaults.shared.object(forKey: key) == nil {
                UserDefaults.shared.set(true, forKey: key)
            }
        }
        
        // 他の設定も同様にデフォルト値を設定
        if UserDefaults.shared.object(forKey: "dailyReminderTime") == nil {
            UserDefaults.shared.set(Calendar.current.date(from: DateComponents(hour: 20)) ?? Date(), forKey: "dailyReminderTime")
        }
        if UserDefaults.shared.object(forKey: "weeklyReportTime") == nil {
            UserDefaults.shared.set(Calendar.current.date(from: DateComponents(hour: 18)) ?? Date(), forKey: "weeklyReportTime")
        }
        if UserDefaults.shared.object(forKey: "weeklyReportWeekday") == nil {
            UserDefaults.shared.set(Calendar.current.component(.weekday, from: Date()), forKey: "weeklyReportWeekday")
        }
        if UserDefaults.shared.object(forKey: "targetDataUsage") == nil {
            UserDefaults.shared.set(0.0, forKey: "targetDataUsage")
        }
    }
    
    private func scheduleAllNotifications() {
        let checker = NotificationConditionChecker()
        
        NotificationType.allCases.forEach { type in
            let key = "notification_\(type.rawValue)_enabled"
            if UserDefaults.shared.bool(forKey: key) && checker.shouldNotify(for: type) {
                scheduleNotification(for: type)
            }
        }
    }
    
    private func scheduleNotification(for type: NotificationType) {
        let content = UNMutableNotificationContent()
        let notificationContent = type.content
        content.title = notificationContent.title
        content.body = notificationContent.body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: checkInterval, repeats: false)
        
        let identifier = "\(type.rawValue)_notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // 既存の同じタイプの通知を削除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // 新しい通知をスケジュール
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(type): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for \(type)")
                UserDefaults.shared.set(Date(), forKey: "lastNotificationTime_\(type.rawValue)")
            }
        }
    }

    private func checkAndUpdateNotifications() {
        saveDataUsage()
        let checker = NotificationConditionChecker()
        
        NotificationType.allCases.forEach { type in
            if UserDefaults.shared.bool(forKey: "notification_\(type.rawValue)_enabled") {
                if checker.shouldNotify(for: type) && canSendNotification(for: type) {
                    scheduleNotification(for: type)
                } else {
                    removeNotifications(for: type)
                }
            }
        }
    }

    private func canSendNotification(for type: NotificationType) -> Bool {
        guard let lastNotificationTime = UserDefaults.shared.object(forKey: "lastNotificationTime_\(type.rawValue)") as? Date else {
            return true
        }
        
        // 同じ日に既に通知を送信している場合は false を返す
        return !Calendar.current.isDate(lastNotificationTime, inSameDayAs: Date())
    }

    private func removeNotifications(for type: NotificationType) {
        let identifier = "\(type.rawValue)_notification"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Cleanup
    deinit {
        cancelAllScheduledTasks()
    }
}
