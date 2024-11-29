import ActivityKit
import WidgetKit
import SwiftUI

struct DataUsageMonitorAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DataUsageMonitorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DataUsageMonitorAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DataUsageMonitorAttributes {
    fileprivate static var preview: DataUsageMonitorAttributes {
        DataUsageMonitorAttributes(name: "World")
    }
}

extension DataUsageMonitorAttributes.ContentState {
    fileprivate static var smiley: DataUsageMonitorAttributes.ContentState {
        DataUsageMonitorAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DataUsageMonitorAttributes.ContentState {
         DataUsageMonitorAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DataUsageMonitorAttributes.preview) {
   DataUsageMonitorLiveActivity()
} contentStates: {
    DataUsageMonitorAttributes.ContentState.smiley
    DataUsageMonitorAttributes.ContentState.starEyes
}
