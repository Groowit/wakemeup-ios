import Foundation

struct WakeHistorySummary: Equatable {
    var recentSuccessRate: Int
    var groupSuccessRate: Int
    var monthTitle: String
    var insightTitle: String
    var insightMessage: String
    var days: [HistoryDay]
}

struct HistoryDay: Identifiable, Equatable {
    let id = UUID()
    var label: String
    var isCurrentMonth: Bool
    var isSuccessful: Bool
    var isHighlighted: Bool = false
}
