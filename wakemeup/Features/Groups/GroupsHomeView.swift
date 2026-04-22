import SwiftUI

struct GroupsHomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            WakeScene {
                if let group = appState.activeGroup {
                    ActiveGroupContent(
                        group: group,
                        onOpenInviteShare: { path.append(BoardRoute.inviteShareActive) },
                        onOpenWakeSetup: { path.append(BoardRoute.wakeSetupEdit) },
                        onOpenMissionPicker: { path.append(BoardRoute.missionPickerEdit) },
                        onOpenAlarm: { path.append(BoardRoute.alarmIntro) },
                        onOpenVoiceRecord: { path.append(BoardRoute.voiceRecord) },
                        onOpenVoiceInbox: { path.append(BoardRoute.voiceInboxAlarm) }
                    )
                } else {
                    EmptyGroupContent(
                        onCreate: {
                            appState.beginGroupCreation()
                            path.append(BoardRoute.createGroup)
                        },
                        onJoin: { path.append(BoardRoute.joinGroup) }
                    )
                }
            }
            .navigationDestination(for: BoardRoute.self) { destination in
                switch destination {
                case .createGroup:
                    CreateGroupView {
                        path.append(BoardRoute.missionPickerCreate)
                    }
                case .missionPickerCreate:
                    MissionPickerView(
                        mode: .groupCreation,
                        initialMissionKind: appState.selectedMissionKind
                    ) {
                        path.append(BoardRoute.inviteShareCreate)
                    }
                case .inviteShareCreate:
                    InviteShareView(mode: .pendingGroup) {
                        path.append(BoardRoute.wakeSetupCreate)
                    }
                case .joinGroup:
                    JoinGroupView {
                        path.append(BoardRoute.wakeSetupJoin)
                    }
                case .wakeSetupCreate:
                    WakeSetupView(mode: .createGroup) {
                        path = NavigationPath()
                    }
                case .wakeSetupJoin:
                    WakeSetupView(mode: .joinGroup) {
                        path = NavigationPath()
                    }
                case .wakeSetupEdit:
                    WakeSetupView(mode: .editExisting) {}
                case .missionPickerEdit:
                    MissionPickerView(
                        mode: .groupSettings,
                        initialMissionKind: appState.activeGroup?.missionKind ?? appState.selectedMissionKind
                    ) {}
                case .inviteShareActive:
                    InviteShareView(mode: .activeGroup) {}
                case .alarmIntro:
                    AlarmIntroView(
                        onStartMission: { path.append(route(for: appState.activeGroup?.missionKind ?? appState.selectedMissionKind)) },
                        onOpenVoiceInbox: { path.append(BoardRoute.voiceInboxAlarm) }
                    )
                case .typingMission:
                    TypingMissionView {
                        path.append(BoardRoute.wakeComplete)
                    }
                case .rapidTapMission:
                    RapidTapMissionView {
                        path.append(BoardRoute.wakeComplete)
                    }
                case .runawayMission:
                    RunawayButtonMissionView {
                        path.append(BoardRoute.wakeComplete)
                    }
                case .voiceRecord:
                    VoiceRecordView {
                        path.append(BoardRoute.voiceInboxPreview)
                    }
                case .voiceInboxAlarm:
                    VoiceInboxView(
                        primaryTitle: "미션 시작",
                        onPrimaryAction: { path.append(route(for: appState.activeGroup?.missionKind ?? appState.selectedMissionKind)) }
                    )
                case .voiceInboxPreview:
                    VoiceInboxView(
                        primaryTitle: "확인",
                        dismissOnPrimaryAction: true,
                        onPrimaryAction: {}
                    )
                case .wakeComplete:
                    WakeCompleteView {
                        path = NavigationPath()
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .wakeTabBarHidden(!path.isEmpty)
    }

    private func route(for missionKind: MissionKind) -> BoardRoute {
        switch missionKind {
        case .typing:
            return .typingMission
        case .rapidTap:
            return .rapidTapMission
        case .chaseButton:
            return .runawayMission
        }
    }
}

private enum BoardRoute: Hashable {
    case createGroup
    case missionPickerCreate
    case inviteShareCreate
    case joinGroup
    case wakeSetupCreate
    case wakeSetupJoin
    case wakeSetupEdit
    case missionPickerEdit
    case inviteShareActive
    case alarmIntro
    case typingMission
    case rapidTapMission
    case runawayMission
    case voiceRecord
    case voiceInboxAlarm
    case voiceInboxPreview
    case wakeComplete
}

private struct EmptyGroupContent: View {
    let onCreate: () -> Void
    let onJoin: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 48)

            ZStack {
                WakeMascotSticker(kind: .sun, size: 70)
                    .offset(x: -92, y: -48)

                WakeMascotSticker(kind: .sleepMoon, size: 72)
                    .offset(x: 88, y: -52)

                WakeMascotSticker(kind: .cat, size: 110)
            }
            .frame(height: 150)

            VStack(spacing: 10) {
                Text("아직 그룹이 없어요!")
                    .font(.wakeHeadline(36))
                    .foregroundStyle(Color.wakeInk)

                Text("친구들을 초대해서 같이 일어나 보세요.")
                    .font(.wakeBody(size: 18, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 14) {
                WakeButton(title: "+ 그룹 만들기", action: onCreate)
                WakeButton(title: "초대 코드로 참여하기", tone: .paper, action: onJoin)
            }
            .frame(maxWidth: 420)

            Spacer(minLength: 80)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ActiveGroupContent: View {
    @EnvironmentObject private var appState: AppState

    let group: WakeGroup
    let onOpenInviteShare: () -> Void
    let onOpenWakeSetup: () -> Void
    let onOpenMissionPicker: () -> Void
    let onOpenAlarm: () -> Void
    let onOpenVoiceRecord: () -> Void
    let onOpenVoiceInbox: () -> Void

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var currentMember: GroupMember? {
        group.members.first(where: \.isCurrentUser)
    }

    private var sleepyFriends: [GroupMember] {
        group.members.filter { !$0.isCurrentUser && $0.status != .awake }
    }

    private var awakeCount: Int {
        group.members.filter { $0.status == .awake }.count
    }

    private var primaryActionTitle: String {
        if currentMember?.status != .awake {
            return appState.latestVoiceNote == nil ? "미션 시작하기" : "친구 음성 듣기"
        }

        return sleepyFriends.isEmpty ? "초대 공유" : "친구 깨우기"
    }

    private var primaryActionCaption: String {
        if currentMember?.status != .awake {
            return appState.latestVoiceNote == nil ? "오늘 미션은 \(group.missionTitle)입니다." : "도착한 음성을 확인하고 바로 미션으로 이어집니다."
        }

        return sleepyFriends.isEmpty ? "다음 멤버를 초대해서 아침 루틴을 확장해 보세요." : "아직 자고 있는 친구에게 음성 알람을 보낼 수 있어요."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text(group.name)
                            .font(.wakeHeadline(42))
                            .foregroundStyle(Color.wakeButter)

                        WakeMascotSticker(kind: .bird, size: 44)
                            .offset(y: -6)
                    }

                    Text(group.dateText)
                        .font(.wakeBody(size: 17, weight: .medium))
                        .foregroundStyle(Color.wakeInkSoft)
                }

                Spacer()

                Text("MY")
                    .font(.wakePixel(14))
                    .foregroundStyle(Color.wakeInk)
                    .frame(width: 54, height: 54)
                    .background {
                        Circle().fill(Color.wakePanelWarm)
                    }
                    .overlay {
                        Circle().stroke(Color.wakeBorder, lineWidth: 1)
                    }
            }

            WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                HStack(alignment: .center) {
                    Text("오늘의 기상 현황")
                        .font(.wakeHeadline(24))
                        .foregroundStyle(Color.wakeInk)

                    Spacer()

                    WakeTape(
                        text: "MISSION: \(group.missionTitle)",
                        fill: Color.wakePanel,
                        ink: .wakeButter
                    )
                }

                HStack(spacing: 8) {
                    ForEach(Array(group.members.enumerated()), id: \.offset) { index, member in
                        Capsule()
                            .fill(stripColor(for: member, index: index))
                            .frame(maxWidth: .infinity)
                            .frame(height: 8)
                            .shadow(color: stripColor(for: member, index: index).opacity(0.4), radius: 10)
                    }
                }

                Text("\(group.members.count)명 중 \(awakeCount)명이 일어났어요! (\(group.completionRate)%)")
                    .font(.wakeBody(size: 15, weight: .semibold))
                    .foregroundStyle(Color.wakeInkSoft)
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("멤버 보드")
                    .font(.wakeHeadline(30))
                    .foregroundStyle(Color.wakeInk)

                LazyVGrid(columns: gridColumns, spacing: 14) {
                    ForEach(group.members) { member in
                        GroupMemberBoardCard(member: member)
                    }
                }
            }

            if !sleepyFriends.isEmpty {
                WakePanel(fill: .wakePaperDeep.opacity(0.84), accent: .wakeButter) {
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.wakeButter)
                                .frame(width: 50, height: 50)
                            Image(systemName: "mic.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.black)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("친구가 자고 있어요!")
                                .font(.wakeBody(size: 18, weight: .bold))
                                .foregroundStyle(Color.wakeInk)

                            Text("친구의 목소리로 깨워주세요.")
                                .font(.wakeBody(size: 14, weight: .medium))
                                .foregroundStyle(Color.wakeInkSoft)
                        }

                        Spacer(minLength: 0)

                        WakeMascotSticker(kind: .wingBird, size: 52)
                    }
                }
            }

            WakeButton(title: primaryActionTitle, caption: primaryActionCaption) {
                if currentMember?.status != .awake {
                    if appState.latestVoiceNote == nil {
                        onOpenAlarm()
                    } else {
                        onOpenVoiceInbox()
                    }
                } else if sleepyFriends.isEmpty {
                    onOpenInviteShare()
                } else {
                    onOpenVoiceRecord()
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("그룹 관리")
                    .font(.wakeHeadline(28))
                    .foregroundStyle(Color.wakeInk)

                HStack(spacing: 12) {
                    BoardActionTile(title: "초대 공유", subtitle: group.inviteCode, tint: .wakeButter, action: onOpenInviteShare)
                    BoardActionTile(title: "기상 시간", subtitle: group.wakeTime, tint: .wakeSky, action: onOpenWakeSetup)
                }

                BoardActionTile(
                    title: "미션 변경",
                    subtitle: group.missionTitle,
                    tint: group.missionKind.tint,
                    action: onOpenMissionPicker
                )
            }
        }
    }

    private func stripColor(for member: GroupMember, index: Int) -> Color {
        if member.status == .awake {
            return .wakeButter
        }

        if member.status == .alerting {
            return .wakeTomato
        }

        if index < awakeCount {
            return .wakeButter
        }

        return .wakeBorder
    }
}

private struct GroupMemberBoardCard: View {
    let member: GroupMember

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                WakeAvatarStamp(
                    avatar: member.avatar,
                    size: 60,
                    fill: member.status.tintColor.opacity(member.status == .beforeWake ? 0.12 : 0.18)
                )

                Spacer()

                Circle()
                    .fill(member.status.tintColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: member.status.tintColor.opacity(0.9), radius: 8)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(member.isCurrentUser ? "\(member.name) (나)" : member.name)
                    .font(.wakeBody(size: 22, weight: .bold))
                    .foregroundStyle(Color.wakeInk)

                Text(member.status.title)
                    .font(.wakeBody(size: 15, weight: .semibold))
                    .foregroundStyle(member.status.tintColor)

                Text(member.wakeRecordText ?? member.memo)
                    .font(.wakeBody(size: 14, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
                    .lineLimit(2)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 174, alignment: .topLeading)
        .background {
            WakePixelShape(cut: 26)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 26)
                .stroke(member.isCurrentUser ? member.status.tintColor.opacity(0.5) : Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: member.isCurrentUser ? member.status.tintColor.opacity(0.16) : .clear, radius: 14)
    }
}

private struct BoardActionTile: View {
    let title: String
    let subtitle: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.wakeBody(size: 16, weight: .bold))
                        .foregroundStyle(Color.wakeInk)

                    Text(subtitle)
                        .font(.wakeBody(size: 13, weight: .medium))
                        .foregroundStyle(tint)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.wakeInkSoft)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                WakePixelShape(cut: 22)
                    .fill(Color.wakePanel)
            }
            .overlay {
                WakePixelShape(cut: 22)
                    .stroke(Color.wakeBorder, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}
