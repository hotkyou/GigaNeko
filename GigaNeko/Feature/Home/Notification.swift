import SwiftUI
import UserNotifications

// MARK: - NotificationType Definition
enum NotificationType: String, CaseIterable {
    case stamina = "stamina"           // スタミナ回復通知
    case stress = "stress"             // ストレス警告通知
    case gigaLimit = "gigaLimit"       // データ使用量限界通知
    case dailyReminder = "dailyReminder" // 日次リマインダー
    case weeklyReport = "weeklyReport"  // 週次レポート
    
    var content: (title: String, body: String) {
        switch self {
        case .stamina:
            return ("餌がなくなりました", "猫がお腹を空かせて待っています！")
        case .stress:
            return ("ストレスが限界です", "猫の機嫌が悪くなっています。癒してあげましょう！")
        case .gigaLimit:
            return ("目標ギガ数に達しました", "データ使用量が制限に近づいています。確認してください。")
        case .dailyReminder:
            let today = Date()
            let dailyUsage = loadHourlyDataUsage(for: today).reduce(0.0) { sum, data in
                sum + (Double(data.wwan) / (1024 * 1024 * 1024))
            }
            return ("今日のデータ通信量", String(format: "今日は%.2fGB使用しました", dailyUsage))
        case .weeklyReport:
            return ("週間レポート", "今週のデータ使用状況をチェックしましょう")
        }
    }
}

class NotificationScheduler {
    static let nshared = NotificationScheduler()
    private var periodicCheckTask: DispatchWorkItem?
    private var isRunning = false
    
    private let checkInterval: TimeInterval = 3600 // 1時間
    private let calendar = Calendar.current
    
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
            switch type {
            case .stamina:
                return giganeko.stamina <= 1
            case .stress:
                return giganeko.stress >= 80
            case .gigaLimit:
                return (Double(dataLimit) - currentUsage) <= targetDataUsage
            case .dailyReminder:
                return shouldSendDailyReminder()
            case .weeklyReport:
                return isWeeklyReportTime()
            }
        }
        
        private func shouldSendDailyReminder() -> Bool {
            guard let lastReminder = UserDefaults.shared.object(forKey: "lastDailyReminder") as? Date else {
                return true
            }
            return !Calendar.current.isDate(lastReminder, inSameDayAs: Date())
        }
        
        private func isWeeklyReportTime() -> Bool {
            guard let lastReport = UserDefaults.shared.object(forKey: "lastWeeklyReport") as? Date else {
                return true
            }
            let weekDifference = Calendar.current.dateComponents([.weekOfYear], from: lastReport, to: Date())
            return weekDifference.weekOfYear ?? 0 >= 1
        }
    }
    
    // MARK: - Public Methods
    func startScheduling() {
        guard !isRunning else { return }
        isRunning = true
        
        scheduleAllNotifications()
        startPeriodicCheck()
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
        
        let trigger: UNNotificationTrigger
        switch type {
        case .dailyReminder:
            var components = DateComponents()
            if let dailyTime = UserDefaults.shared.object(forKey: "dailyReminderTime") as? Date {
                components.hour = calendar.component(.hour, from: dailyTime)
                components.minute = calendar.component(.minute, from: dailyTime)
            } else {
                components.hour = 20  // デフォルト値
                components.minute = 0
            }
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        case .weeklyReport:
            var components = DateComponents()
            if let weeklyTime = UserDefaults.shared.object(forKey: "weeklyReportTime") as? Date {
                components.hour = calendar.component(.hour, from: weeklyTime)
                components.minute = calendar.component(.minute, from: weeklyTime)
            } else {
                components.hour = 18  // デフォルト値
                components.minute = 0
            }
            components.weekday = UserDefaults.shared.integer(forKey: "weeklyReportWeekday")
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
        default:
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: checkInterval, repeats: false)
        }
        
        let request = UNNotificationRequest(
            identifier: "\(type.rawValue)_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
            semaphore.signal()
        }
        
        _ = semaphore.wait(timeout: .now() + 5.0)
    }
    
    private func checkAndUpdateNotifications() {
        saveDataUsage()
        let checker = NotificationConditionChecker()
        
        NotificationType.allCases.forEach { type in
            if UserDefaults.shared.bool(forKey: "notification_\(type.rawValue)_enabled") {
                if checker.shouldNotify(for: type) {
                    scheduleNotification(for: type)
                } else {
                    removeNotifications(for: type)
                }
            }
        }
    }
    
    private func removeNotifications(for type: NotificationType) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.starts(with: type.rawValue) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    // MARK: - Cleanup
    deinit {
        cancelAllScheduledTasks()
    }
}
