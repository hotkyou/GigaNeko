import SwiftUI
import ActivityKit
import WidgetKit
//import Firebase
import BackgroundTasks

@main
struct GigaNekoApp: App {
    // Firebaseの初期化
    init() {
        //FirebaseApp.configure()
        saveDataUsage()
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
    let refreshTaskIdentifier = "hotkyou.GigaNeko.refresh"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // バックグラウンドタスクの登録
        BGTaskScheduler.shared.register(forTaskWithIdentifier: refreshTaskIdentifier, using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        // バックグラウンドタスクのスケジュール設定
        scheduleAppRefresh()
        print("アプリ起動")
        return true
    }
    
//    func startDataUsageMonitoring() {
//        let attributes = DataUsageMonitorAttributes(name: "Data Usage")
//        let contentState = DataUsageMonitorAttributes.ContentState(emoji: "📊")
//        
//        do {
//            let initialContentState = ActivityContent(state: contentState, staleDate: nil)
//            let activity = try Activity<DataUsageMonitorAttributes>.request(
//                attributes: attributes,
//                content: initialContentState,
//                pushType: nil
//            )
//            print("Requested a Live Activity \(activity.id)")
//        } catch (let error) {
//            print("Error requesting Live Activity \(error.localizedDescription)")
//        }
//    }
    
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
