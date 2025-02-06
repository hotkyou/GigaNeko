import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "データ使用量ウィジェット" }

    // An example configurable parameter.
    @Parameter(title: "ねこ", default: "🐈")
    var NekoEmoji: String
}
