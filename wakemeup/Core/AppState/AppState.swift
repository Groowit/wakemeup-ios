import AVFAudio
import Combine
import Foundation
import UserNotifications

@MainActor
final class AppState: ObservableObject {
    enum RootDestination: Equatable {
        case onboarding
        case auth
        case main
    }

    enum MainTab: Hashable {
        case groups
        case history
        case profile
    }

    enum AuthStep: Equatable {
        case avatar
        case nickname
    }

    enum PermissionState: Equatable {
        case notRequested
        case authorized
        case denied

        var title: String {
            switch self {
            case .notRequested:
                return "미설정"
            case .authorized:
                return "허용됨"
            case .denied:
                return "허용 안 됨"
            }
        }
    }

    enum NicknameValidation: Equatable {
        case empty
        case tooShort
        case tooLong
        case invalidCharacters
        case valid

        var message: String {
            switch self {
            case .empty:
                return "닉네임을 입력해 주세요."
            case .tooShort:
                return "닉네임은 2자 이상이어야 합니다."
            case .tooLong:
                return "닉네임은 12자 이하로 입력해 주세요."
            case .invalidCharacters:
                return "한글, 영문, 숫자만 사용할 수 있습니다."
            case .valid:
                return "사용할 수 있는 닉네임입니다."
            }
        }

        var isValid: Bool {
            if case .valid = self {
                return true
            }

            return false
        }
    }

    @Published var hasSeenOnboarding: Bool
    @Published var isAuthenticated: Bool
    @Published var selectedTab: MainTab
    @Published var currentUser: UserProfile
    @Published var activeGroup: WakeGroup?
    @Published var historySummary: WakeHistorySummary
    @Published var selectedMissionKind: MissionKind
    @Published var selectedAvatar: AvatarSticker
    @Published var authStep: AuthStep
    @Published var authNickname: String
    @Published var notificationPermissionState: PermissionState
    @Published var microphonePermissionState: PermissionState
    @Published var pendingGroupDraft: GroupDraft?
    @Published var wakeTime: Date
    @Published var wakeDays: Set<WakeWeekday>
    @Published var wakePhrase: String
    @Published var latestVoiceNote: VoiceAlarmNote?

    let onboardingPages: [OnboardingPage]
    let availableMissions: [MissionTemplate]

    init(
        hasSeenOnboarding: Bool = false,
        isAuthenticated: Bool = false,
        selectedTab: MainTab = .groups,
        currentUser: UserProfile = MockData.currentUser,
        activeGroup: WakeGroup? = nil,
        historySummary: WakeHistorySummary = MockData.historySummary,
        selectedMissionKind: MissionKind = .typing,
        selectedAvatar: AvatarSticker = MockData.currentUser.avatar,
        authStep: AuthStep = .avatar,
        authNickname: String = "",
        notificationPermissionState: PermissionState = .notRequested,
        microphonePermissionState: PermissionState = .notRequested,
        pendingGroupDraft: GroupDraft? = nil,
        wakeTime: Date = AppState.makeWakeTime(hour: 7, minute: 25),
        wakeDays: Set<WakeWeekday> = [.mon, .tue, .wed, .thu, .fri],
        wakePhrase: String = "나는 오늘 7시 25분 전에 책상 앞에 앉아 있다.",
        latestVoiceNote: VoiceAlarmNote? = MockData.voiceNote,
        onboardingPages: [OnboardingPage] = MockData.onboardingPages,
        availableMissions: [MissionTemplate] = MockData.missionTemplates
    ) {
        self.hasSeenOnboarding = hasSeenOnboarding
        self.isAuthenticated = isAuthenticated
        self.selectedTab = selectedTab
        self.currentUser = currentUser
        self.activeGroup = activeGroup
        self.historySummary = historySummary
        self.selectedMissionKind = selectedMissionKind
        self.selectedAvatar = selectedAvatar
        self.authStep = authStep
        self.authNickname = authNickname
        self.notificationPermissionState = notificationPermissionState
        self.microphonePermissionState = microphonePermissionState
        self.pendingGroupDraft = pendingGroupDraft
        self.wakeTime = wakeTime
        self.wakeDays = wakeDays
        self.wakePhrase = wakePhrase
        self.latestVoiceNote = latestVoiceNote
        self.onboardingPages = onboardingPages
        self.availableMissions = availableMissions
    }

    var rootDestination: RootDestination {
        if !hasSeenOnboarding {
            return .onboarding
        }

        if !isAuthenticated {
            return .auth
        }

        return .main
    }

    var selectedMission: MissionTemplate {
        availableMissions.first(where: { $0.kind == selectedMissionKind }) ?? availableMissions[0]
    }

    var formattedWakeTime: String {
        Self.timeFormatter.string(from: wakeTime)
    }

    var authNicknameValidation: NicknameValidation {
        let trimmed = authNickname.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return .empty
        }

        if trimmed.count < 2 {
            return .tooShort
        }

        if trimmed.count > 12 {
            return .tooLong
        }

        let pattern = "^[가-힣A-Za-z0-9]+$"
        if trimmed.range(of: pattern, options: .regularExpression) == nil {
            return .invalidCharacters
        }

        return .valid
    }

    func finishOnboarding() {
        hasSeenOnboarding = true
        resetAuthDraft()
    }

    func skipToAuth() {
        hasSeenOnboarding = true
        resetAuthDraft()
    }

    func selectAuthAvatar(_ avatar: AvatarSticker) {
        selectedAvatar = avatar
    }

    func advanceAuthStep() {
        authStep = .nickname
    }

    func retreatAuthStep() {
        authStep = .avatar
    }

    func completeAuthentication() {
        guard authNicknameValidation.isValid else { return }

        let nickname = authNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        currentUser.displayName = nickname
        currentUser.nickname = nickname
        currentUser.avatar = selectedAvatar
        currentUser.preferredWakeTime = formattedWakeTime
        syncCurrentUserIntoActiveGroup()
        isAuthenticated = true
        authStep = .avatar
    }

    func signOut() {
        isAuthenticated = false
        selectedTab = .groups
        activeGroup = nil
        pendingGroupDraft = nil
        latestVoiceNote = MockData.voiceNote
        resetAuthDraft()
    }

    func beginGroupCreation() {
        pendingGroupDraft = GroupDraft(source: .create, inviteCode: Self.makeInviteCode())
    }

    func updatePendingGroup(name: String, memberCount: Int) {
        if pendingGroupDraft == nil {
            beginGroupCreation()
        }

        pendingGroupDraft?.name = name
        pendingGroupDraft?.memberCount = memberCount
    }

    func prepareJoinGroup(inviteCode: String) {
        pendingGroupDraft = GroupDraft(
            source: .join,
            name: "",
            memberCount: 4,
            inviteCode: inviteCode.uppercased()
        )
    }

    func clearPendingGroup() {
        pendingGroupDraft = nil
    }

    func activateGroupFromPendingDraft() {
        guard let pendingGroupDraft else { return }

        saveWakeSchedule()
        activeGroup = MockData.makeGroup(
            name: pendingGroupDraft.resolvedName,
            inviteCode: pendingGroupDraft.inviteCode,
            currentUser: currentUser,
            mission: selectedMission,
            memberCount: pendingGroupDraft.memberCount,
            wakeTime: formattedWakeTime
        )
        selectedTab = .groups
        self.pendingGroupDraft = nil
    }

    func clearActiveGroup() {
        activeGroup = nil
        selectedTab = .groups
    }

    func selectMission(_ mission: MissionTemplate) {
        selectedMissionKind = mission.kind
    }

    func applyMissionToActiveGroup(_ mission: MissionTemplate) {
        selectedMissionKind = mission.kind

        guard var activeGroup else { return }
        activeGroup.missionKind = mission.kind
        activeGroup.missionTitle = mission.title
        activeGroup.boardFootnote = "\(mission.title) 미션으로 진행합니다."
        self.activeGroup = activeGroup
    }

    func toggleWakeDay(_ day: WakeWeekday) {
        if wakeDays.contains(day) {
            wakeDays.remove(day)
        } else {
            wakeDays.insert(day)
        }
    }

    func saveWakeSchedule() {
        currentUser.preferredWakeTime = formattedWakeTime

        guard var activeGroup else { return }
        activeGroup.wakeTime = formattedWakeTime
        activeGroup.dateText = Self.dayFormatter.string(from: .now)
        self.activeGroup = activeGroup
    }

    func completeWakeSession() {
        let completedAt = Self.timeFormatter.string(from: .now)

        currentUser.preferredWakeTime = formattedWakeTime
        currentUser.currentStreakDays += 1
        currentUser.weeklySuccessRate = min(currentUser.weeklySuccessRate + 2, 100)

        guard var activeGroup else { return }

        if let index = activeGroup.members.firstIndex(where: \.isCurrentUser) {
            activeGroup.members[index].status = .awake
            activeGroup.members[index].wakeRecordText = completedAt
            activeGroup.members[index].memo = "\(completedAt)에 기상 완료"
        }

        let awakeCount = activeGroup.members.filter { $0.status == .awake }.count
        let remainingCount = activeGroup.members.count - awakeCount
        activeGroup.completionRate = Int((Double(awakeCount) / Double(max(activeGroup.members.count, 1))) * 100)
        activeGroup.boardHeadline = remainingCount == 0 ? "오늘 그룹 기상이 모두 완료되었습니다." : "\(awakeCount)명 완료, \(remainingCount)명 진행 중"
        activeGroup.boardFootnote = remainingCount == 0 ? "내일도 같은 시간에 이어집니다." : "먼저 일어난 친구는 아직 진행 중인 멤버에게 음성을 보낼 수 있습니다."
        self.activeGroup = activeGroup
        selectedTab = .groups
    }

    func saveRecordedVoiceNote(durationSeconds: Int) {
        let recipients = activeGroup?.members
            .filter { !$0.isCurrentUser && $0.status != .awake }
            .map(\.name) ?? []

        latestVoiceNote = VoiceAlarmNote(
            id: UUID(),
            senderName: currentUser.displayName,
            recipients: recipients,
            summary: "지금 확인하고 바로 준비해요.",
            durationSeconds: durationSeconds
        )

        guard var activeGroup else { return }
        for index in activeGroup.members.indices where !activeGroup.members[index].isCurrentUser && activeGroup.members[index].status != .awake {
            activeGroup.members[index].voiceMessageTitle = "\(currentUser.displayName) 음성 도착"
        }
        self.activeGroup = activeGroup
    }

    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            notificationPermissionState = granted ? .authorized : .denied
            return granted
        } catch {
            notificationPermissionState = .denied
            return false
        }
    }

    func requestMicrophonePermission() async -> Bool {
        let granted = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        microphonePermissionState = granted ? .authorized : .denied
        return granted
    }

    func reset(to destination: RootDestination) {
        hasSeenOnboarding = destination != .onboarding
        isAuthenticated = destination == .main
        selectedTab = .groups
        activeGroup = destination == .main ? MockData.makeGroup(currentUser: currentUser, mission: selectedMission, wakeTime: formattedWakeTime) : nil
        selectedMissionKind = .typing
        selectedAvatar = currentUser.avatar
        pendingGroupDraft = nil
        wakeTime = Self.makeWakeTime(hour: 7, minute: 25)
        wakeDays = [.mon, .tue, .wed, .thu, .fri]
        wakePhrase = "나는 오늘 7시 25분 전에 책상 앞에 앉아 있다."
        latestVoiceNote = MockData.voiceNote
        notificationPermissionState = .notRequested
        microphonePermissionState = .notRequested
        resetAuthDraft()
    }

    private func syncCurrentUserIntoActiveGroup() {
        guard var activeGroup else { return }
        if let index = activeGroup.members.firstIndex(where: \.isCurrentUser) {
            activeGroup.members[index].name = currentUser.displayName
            activeGroup.members[index].avatar = currentUser.avatar
        }
        self.activeGroup = activeGroup
    }

    private func resetAuthDraft() {
        authStep = .avatar
        authNickname = ""
        selectedAvatar = currentUser.avatar
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    private static func makeInviteCode() -> String {
        let letters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).compactMap { _ in letters.randomElement() })
    }

    private nonisolated static func makeWakeTime(hour: Int, minute: Int) -> Date {
        Calendar.current.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: .now
        ) ?? .now
    }
}
