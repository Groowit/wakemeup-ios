import Foundation

enum AvatarSticker: String, CaseIterable, Equatable, Identifiable {
    case rabbit
    case chick
    case cloud
    case moon

    var id: String { rawValue }

    var title: String {
        switch self {
        case .rabbit:
            return "토끼"
        case .chick:
            return "병아리"
        case .cloud:
            return "구름"
        case .moon:
            return "달"
        }
    }

    var note: String {
        switch self {
        case .rabbit:
            return "빠르게 반응하는 타입"
        case .chick:
            return "소란스러워도 금방 움직임"
        case .cloud:
            return "천천히 시작하지만 꾸준함"
        case .moon:
            return "밤에 강하고 아침엔 신중함"
        }
    }
}

enum WakeWeekday: String, CaseIterable, Hashable, Identifiable {
    case mon = "월"
    case tue = "화"
    case wed = "수"
    case thu = "목"
    case fri = "금"
    case sat = "토"
    case sun = "일"

    var id: String { rawValue }
}

struct UserProfile: Identifiable, Equatable {
    let id: UUID
    var displayName: String
    var nickname: String
    var avatar: AvatarSticker
    var hangoutLine: String
    var weeklySuccessRate: Int
    var currentStreakDays: Int
    var preferredWakeTime: String
}
