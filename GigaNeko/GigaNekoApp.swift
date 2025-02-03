import SwiftUI
import ActivityKit
import WidgetKit
import BackgroundTasks

@main
struct GigaNekoApp: App {
    init() {
        saveDataUsage()
        NotificationScheduler.nshared.startScheduling()
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    // バックグラウンドタスクの識別子
    let refreshTaskIdentifier = "\(Identifier.groupIdentifier).refresh"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 通知のデリゲート設定を追加
        UNUserNotificationCenter.current().delegate = self
        
        // 既存のバックグラウンドタスクの設定
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        scheduleAppRefresh()
        print("アプリ起動")
        return true
    }
    
    // タスクのスケジュールを設定する関数
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 50 * 60) // 最短で15分後に実行
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule app refresh: \(error)")
        }
    }
    
    // フォアグラウンドでの通知表示を許可
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // タスクが実行された際に呼び出される処理
    func handleAppRefresh(task: BGAppRefreshTask) {
        // 次回の実行をスケジュール
        scheduleAppRefresh()
        print("タスク実行")
        
        // 通信量を取得して保存
        saveDataUsage()
        
        
        // タスク完了のマネージメント
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        task.setTaskCompleted(success: true)
    }
}
