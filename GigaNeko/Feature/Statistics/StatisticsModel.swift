import Foundation

enum TimeSegment: String, CaseIterable {
    case daily = "日"
    case weekly = "週"
    case monthly = "月"
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .monthly: return .month
        }
    }
    
    var strideComponent: Calendar.Component {
        switch self {
        case .daily: return .hour
        case .weekly, .monthly: return .day
        }
    }
}

struct DataPoint: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let wifi: Double
    let wwan: Double
    
    var total: Double { wifi + wwan }
    
    static func == (lhs: DataPoint, rhs: DataPoint) -> Bool {
        return lhs.id == rhs.id &&
               lhs.date == rhs.date &&
               lhs.wifi == rhs.wifi &&
               lhs.wwan == rhs.wwan
    }
}
