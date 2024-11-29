import WidgetKit
import SwiftUI

@main
struct DataUsageMonitorBundle: WidgetBundle {
    var body: some Widget {
        DataUsageMonitor()
        DataUsageMonitorControl()
        DataUsageMonitorLiveActivity()
    }
}
