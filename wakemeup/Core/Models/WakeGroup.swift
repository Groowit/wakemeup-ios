import Foundation

struct WakeGroup: Identifiable, Equatable {
    let id: UUID
    var name: String
    var inviteCode: String
    var wakeTime: String
    var dateText: String
    var boardHeadline: String
    var boardFootnote: String
    var missionKind: MissionKind
    var missionTitle: String
    var completionRate: Int
    var memberLimit: Int
    var members: [GroupMember]
}

struct VoiceAlarmNote: Identifiable, Equatable {
    let id: UUID
    var senderName: String
    var recipients: [String]
    var summary: String
    var durationSeconds: Int
}

struct GroupMember: Identifiable, Equatable {
    let id: UUID
    var name: String
    var avatar: AvatarSticker
    var memo: String
    var status: GroupMemberStatus
    var isCurrentUser: Bool
    var wakeRecordText: String?
    var voiceMessageTitle: String?
}

enum GroupMemberStatus: String, CaseIterable, Equatable {
    case beforeWake
    case alerting
    case awake
    case failed

    var title: String {
        switch self {
        case .beforeWake:
            return "기상 전"
        case .alerting:
            return "알림 진행 중"
        case .awake:
            return "기상 완료"
        case .failed:
            return "실패"
        }
    }
}
