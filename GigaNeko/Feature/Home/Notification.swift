import SwiftUI

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("通知の許可が得られました")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

class NotificationScheduler {
    static let nshared = NotificationScheduler()
    private var scheduledTask: DispatchWorkItem?
    @AppStorage("lastScheduledTime") private var lastScheduledTime: Date?
    
    func startScheduling() {
        cancelScheduledTask()
        
        let task = DispatchWorkItem { [weak self] in
            self?.executeScheduledTask()
        }
        scheduledTask = task
        
        let nextExecutionDelay = calculateNextExecutionDelay()
        DispatchQueue.main.asyncAfter(deadline: .now() + nextExecutionDelay, execute: task)
        lastScheduledTime = Date()
    }
    
    private func executeScheduledTask() {
        scheduleNotification()
        startScheduling()
    }
    
    private func calculateNextExecutionDelay() -> TimeInterval {
        if let lastScheduled = lastScheduledTime {
            let timeSinceLastSchedule = Date().timeIntervalSince(lastScheduled)
            if timeSinceLastSchedule < 3600 {
                return 3600 - timeSinceLastSchedule
            }
        }
        return 3600
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        
        switch getNotificationType() {
        case .noEsa:
            content.title = "スタミナが回復しました"
            content.body = "再び遊べるようになりました"
        case .stressUp:
            content.title = "ストレスが限界です"
            content.body = "猫の機嫌が悪くなっています"
        case .gigaLimit:
            content.title = "目標ギガ数に達しました"
            content.body = "猫がブチギレています"
        case .dailyGiga:
            content.title = "今日の使用データ量"
            content.body = "3GB使用しました"
        case .nothing:
            return
        }
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    private enum NotificationType {
        case noEsa
        case stressUp
        case gigaLimit
        case dailyGiga
        case nothing
    }
    
    private func getNotificationType() -> NotificationType {
        // 通知を表示する条件
        // 餌がない、ストレスが高い、設定ギガ数１GB未満、1日の使用量
//        if giganekoPoint.stamina >= 100 {
//            return .noEsa
//        } else if giganekoPoint.stress >= 80 {
//            return .stressUp
//        } else if {
//            return .gigaLimit
//        } else {
//            return .nothing
//        }
        return .nothing //仮置き
    }
    
    func cancelScheduledTask() {
        scheduledTask?.cancel()
        scheduledTask = nil
    }
}
