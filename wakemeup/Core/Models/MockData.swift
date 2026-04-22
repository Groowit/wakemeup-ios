import Foundation

enum MockData {
    static let onboardingPages: [OnboardingPage] = [
        OnboardingPage(
            id: UUID(),
            title: "같은 목표로 함께 일어납니다",
            subtitle: "친구와 기상 시간을 맞추고 서로의 상태를 확인할 수 있어요."
        ),
        OnboardingPage(
            id: UUID(),
            title: "기상 상태가 바로 공유됩니다",
            subtitle: "누가 완료했고 누가 진행 중인지 그룹 홈에서 한눈에 확인합니다."
        ),
        OnboardingPage(
            id: UUID(),
            title: "미션을 마쳐야 오늘 기상이 끝납니다",
            subtitle: "짧지만 확실한 동작으로 잠에서 완전히 벗어나게 도와줍니다."
        )
    ]

    static let missionTemplates: [MissionTemplate] = [
        MissionTemplate(
            id: UUID(),
            kind: .typing,
            title: "타자치기",
            detail: "문장을 정확히 입력하면 기상이 완료됩니다.",
            badgeText: "TXT",
            sampleText: "예: 나는 오늘 7시 25분 전에 책상 앞에 앉아 있다."
        ),
        MissionTemplate(
            id: UUID(),
            kind: .rapidTap,
            title: "100번 연타",
            detail: "연속 탭으로 게이지를 채워야 종료됩니다.",
            badgeText: "100 TAP",
            sampleText: "멈추면 게이지가 다시 내려갑니다."
        ),
        MissionTemplate(
            id: UUID(),
            kind: .chaseButton,
            title: "도망가는 버튼",
            detail: "움직이는 버튼을 연속으로 눌러야 합니다.",
            badgeText: "RUN 10",
            sampleText: "열 번 모두 눌러야 기상이 완료됩니다."
        )
    ]

    static let currentUser = UserProfile(
        id: UUID(),
        displayName: "예영",
        nickname: "예영",
        avatar: .rabbit,
        hangoutLine: "평일 오전 루틴을 안정적으로 만들고 있어요.",
        weeklySuccessRate: 86,
        currentStreakDays: 7,
        preferredWakeTime: "07:25"
    )

    static let defaultGroup = makeGroup(currentUser: currentUser)

    static let voiceNote = VoiceAlarmNote(
        id: UUID(),
        senderName: "서윤",
        recipients: ["민수", "예영"],
        summary: "지금 바로 일어나. 3분 뒤에 다시 확인할게.",
        durationSeconds: 8
    )

    static let historySummary = WakeHistorySummary(
        recentSuccessRate: 86,
        groupSuccessRate: 78,
        monthTitle: "2026년 4월",
        insightTitle: "이번 주 요약",
        insightMessage: "평일 기준 대부분 제시간에 기상을 완료했어요.",
        days: makeHistoryDays()
    )

    static func makeGroup(
        name: String? = nil,
        inviteCode: String? = nil,
        currentUser: UserProfile = currentUser,
        mission: MissionTemplate? = nil,
        memberCount: Int? = nil,
        wakeTime: String = "07:25"
    ) -> WakeGroup {
        let selectedMission = mission ?? missionTemplates[0]
        let limitedCount = min(max(memberCount ?? 4, 2), 4)
        let trimmedName = name?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedInviteCode = inviteCode?.trimmingCharacters(in: .whitespacesAndNewlines)

        let baseMembers: [GroupMember] = [
            GroupMember(
                id: UUID(),
                name: currentUser.displayName,
                avatar: currentUser.avatar,
                memo: "알림 확인 후 미션 대기",
                status: .alerting,
                isCurrentUser: true,
                wakeRecordText: nil,
                voiceMessageTitle: nil
            ),
            GroupMember(
                id: UUID(),
                name: "민수",
                avatar: .moon,
                memo: "첫 알림 이후 아직 응답이 없어요",
                status: .alerting,
                isCurrentUser: false,
                wakeRecordText: nil,
                voiceMessageTitle: "서윤 음성 도착"
            ),
            GroupMember(
                id: UUID(),
                name: "지성",
                avatar: .cloud,
                memo: "예정된 기상 시간 전입니다",
                status: .beforeWake,
                isCurrentUser: false,
                wakeRecordText: nil,
                voiceMessageTitle: nil
            ),
            GroupMember(
                id: UUID(),
                name: "서윤",
                avatar: .chick,
                memo: "가장 먼저 기상을 완료했어요",
                status: .awake,
                isCurrentUser: false,
                wakeRecordText: "07:12",
                voiceMessageTitle: nil
            )
        ]

        return WakeGroup(
            id: UUID(),
            name: (trimmedName?.isEmpty == false ? trimmedName : nil) ?? "아침 루틴 팀",
            inviteCode: (trimmedInviteCode?.isEmpty == false ? trimmedInviteCode?.uppercased() : nil) ?? "G7M9Q2",
            wakeTime: wakeTime,
            dateText: "4월 19일 일요일",
            boardHeadline: "1명 완료, 2명 진행 중",
            boardFootnote: "\(selectedMission.title) 미션으로 오늘 기상을 확인합니다.",
            missionKind: selectedMission.kind,
            missionTitle: selectedMission.title,
            completionRate: 33,
            memberLimit: limitedCount,
            members: Array(baseMembers.prefix(limitedCount))
        )
    }

    private static func makeHistoryDays() -> [HistoryDay] {
        let labels = [
            "30", "31", "1", "2", "3", "4", "5",
            "6", "7", "8", "9", "10", "11", "12",
            "13", "14", "15", "16", "17", "18", "19",
            "20", "21", "22", "23", "24", "25", "26",
            "27", "28", "29", "30", "", "", ""
        ]
        let successfulLabels: Set<String> = ["2", "3", "4", "6", "7", "9", "10", "14", "15", "17", "21", "23", "24", "25"]

        return labels.map { label in
            HistoryDay(
                label: label,
                isCurrentMonth: label != "30" && label != "31" && !label.isEmpty,
                isSuccessful: successfulLabels.contains(label),
                isHighlighted: label == "7"
            )
        }
    }
}
