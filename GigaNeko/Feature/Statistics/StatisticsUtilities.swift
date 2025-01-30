import Foundation

func formatDate(_ date: Date, for segment: TimeSegment) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    
    switch segment {
    case .daily:
        formatter.dateFormat = "H時"
    case .weekly:
        formatter.dateFormat = "M/d (E)"
    case .monthly:
        formatter.dateFormat = "M/d"
    }
    return formatter.string(from: date)
}

struct HourlyUsage {
    let hour: Int
    let wifi: Int64
    let wwan: Int64
}

struct DailyUsage {
    let day: Int
    let wifi: Int64
    let wwan: Int64
}
