import SwiftUI
import Firebase
import BackgroundTasks

@main
struct GigaNekoApp: App {
    // Firebaseの初期化
    init() {
        FirebaseApp.configure()
    }
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    // バックグラウンドタスクの識別子
    let refreshTaskIdentifier = "Iccyan21.GigaNeko.refresh"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // バックグラウンドタスクの登録
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        // バックグラウンドタスクのスケジュール設定
        scheduleAppRefresh()
        return true
    }
    
    // タスクのスケジュールを設定する関数
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 最短で15分後に実行
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule app refresh: \(error)")
        }
    }
    
    // タスクが実行された際に呼び出される処理
    func handleAppRefresh(task: BGAppRefreshTask) {
        // 次回の実行をスケジュール
        scheduleAppRefresh()
        
        // 通信量を取得して保存
        let dataUsage = DataUsageManager.getDataUsage()
        DataUsageManager.saveDataUsage(dataUsage)
        
        // タスク完了のマネージメント
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        task.setTaskCompleted(success: true)
    }
}
