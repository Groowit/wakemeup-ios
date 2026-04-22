import SwiftUI

struct AlarmIntroView: View {
    @EnvironmentObject private var appState: AppState

    let onStartMission: () -> Void
    let onOpenVoiceInbox: () -> Void

    private var mission: MissionTemplate {
        appState.selectedMission
    }

    private var waitingCount: Int {
        appState.activeGroup?.members.filter { !$0.isCurrentUser && $0.status != .awake }.count ?? 0
    }

    var body: some View {
        WakeScene(bottomInset: 24) {
            VStack(spacing: 18) {
                Spacer(minLength: 14)

                HStack(spacing: 12) {
                    WakeMascotSticker(kind: .sun, size: 50)

                    Text("WAKE UP NOW!")
                        .font(.wakePixel(15))
                        .foregroundStyle(Color.wakePlum)
                        .tracking(1.5)

                    WakeMascotSticker(kind: .sleepMoon, size: 50)
                }

                Text(appState.currentUser.preferredWakeTime)
                    .font(.wakeDisplay(82))
                    .foregroundStyle(Color.wakeInk)

                WakeTape(
                    text: appState.latestVoiceNote == nil ? "오늘의 기상 미션" : "그룹 알람 전송 중...",
                    fill: .wakePanelWarm,
                    ink: appState.latestVoiceNote == nil ? .wakeButter : .wakePlum
                )

                Text(appState.activeGroup?.name ?? appState.currentUser.displayName)
                    .font(.wakeHeadline(40))
                    .foregroundStyle(Color.wakeInk)

                Text("멤버 \(waitingCount)명이 기다리고 있어요")
                    .font(.wakeBody(size: 19, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)

                Spacer(minLength: 24)

                WakeButton(
                    title: appState.latestVoiceNote == nil ? "미션 시작하기" : "친구 음성 듣기"
                ) {
                    if appState.latestVoiceNote == nil {
                        onStartMission()
                    } else {
                        onOpenVoiceInbox()
                    }
                }

                Text("5분 뒤에 다시 알림 (2/3)")
                    .font(.wakeBody(size: 16, weight: .semibold))
                    .foregroundStyle(Color.wakeInkSoft)

                WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                    HStack(alignment: .center, spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(Color.wakeButter.opacity(0.18))
                                .frame(width: 46, height: 46)

                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(Color.wakeButter)
                        }

                        Text("브라우저 설정 특성상 앱이 활성화된 상태에서만 확실한 알림이 작동합니다. 화면을 끄지 마세요.")
                            .font(.wakeBody(size: 14, weight: .medium))
                            .foregroundStyle(Color.wakeInkSoft)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct TypingMissionView: View {
    @EnvironmentObject private var appState: AppState
    @FocusState private var isFieldFocused: Bool
    @State private var typedText = ""

    let onComplete: () -> Void

    private var targetText: String {
        appState.wakePhrase
    }

    var body: some View {
        WakeMissionShell(title: "타자치기", accent: .wakeButter) {
            Text("아래 문장을 똑같이 입력하세요")
                .font(.wakeBody(size: 16, weight: .medium))
                .foregroundStyle(Color.wakeInkSoft)

            WakePanel(fill: .wakePanelWarm, accent: .wakeBorder) {
                Text(targetText)
                    .font(.wakeHeadline(22))
                    .foregroundStyle(Color.wakeInk)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
                    .multilineTextAlignment(.center)
            }

            ZStack(alignment: .topLeading) {
                WakePixelShape(cut: 30)
                    .fill(Color.wakePanel)
                    .overlay {
                        WakePixelShape(cut: 30)
                            .stroke(Color.wakeButter.opacity(0.82), lineWidth: 1)
                    }

                if typedText.isEmpty {
                    Text("여기에 입력...")
                        .font(.wakeBody(size: 18, weight: .medium))
                        .foregroundStyle(Color.wakeInkSoft.opacity(0.7))
                        .padding(.horizontal, 22)
                        .padding(.vertical, 20)
                }

                TextEditor(text: $typedText)
                    .focused($isFieldFocused)
                    .font(.wakeBody(size: 18, weight: .semibold))
                    .foregroundStyle(Color.wakeInk)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(minHeight: 150)
                    .onChange(of: typedText) { _, newValue in
                        if newValue == targetText {
                            finishMission()
                        }
                    }
            }

            Text("\(typedText.count) / \(targetText.count) 글자")
                .font(.wakeBody(size: 15, weight: .semibold))
                .foregroundStyle(Color.wakeInkSoft)
                .frame(maxWidth: .infinity)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            isFieldFocused = true
        }
    }

    private func finishMission() {
        guard typedText == targetText else { return }
        appState.completeWakeSession()
        onComplete()
    }
}

struct RapidTapMissionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var tapCount = 0
    @State private var lastTapDate = Date()

    let onComplete: () -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        WakeMissionShell(title: "100번 연타", accent: .wakeSky) {
            Text("화면을 100번 연타하세요")
                .font(.wakeBody(size: 16, weight: .medium))
                .foregroundStyle(Color.wakeInkSoft)

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text("\(tapCount)")
                    .font(.wakeDisplay(64))
                    .foregroundStyle(Color.wakeInk)

                Text("/ 100")
                    .font(.wakeHeadline(30))
                    .foregroundStyle(Color.wakeInkSoft)
            }

            Button {
                guard tapCount < 100 else { return }
                tapCount += 1
                lastTapDate = .now

                if tapCount >= 100 {
                    appState.completeWakeSession()
                    onComplete()
                }
            } label: {
                WakeLiquidCircle(progress: progress, tint: .wakeSky, label: "TAP READY")
                    .frame(width: 290, height: 290)
            }
            .buttonStyle(.plain)

            WakeMissionProgressBar(progress: progress, tint: .wakeSky)
        }
        .onReceive(timer) { _ in
            guard tapCount > 0, tapCount < 100 else { return }
            if Date().timeIntervalSince(lastTapDate) > 0.8 {
                tapCount = max(0, tapCount - 4)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var progress: CGFloat {
        CGFloat(tapCount) / 100
    }
}

struct RunawayButtonMissionView: View {
    @EnvironmentObject private var appState: AppState
    @State private var catches = 0
    @State private var currentOffset = CGSize(width: -90, height: -70)

    let onComplete: () -> Void

    private let positions: [CGSize] = [
        CGSize(width: -96, height: -92),
        CGSize(width: 90, height: -64),
        CGSize(width: -72, height: 46),
        CGSize(width: 82, height: 86),
        CGSize(width: 0, height: 0),
        CGSize(width: -18, height: 108)
    ]

    var body: some View {
        WakeMissionShell(title: "버튼 잡기", accent: .wakeButter) {
            Text("움직이는 버튼을 잡으세요")
                .font(.wakeBody(size: 16, weight: .medium))
                .foregroundStyle(Color.wakeInkSoft)

            Text("\(catches) / 10")
                .font(.wakeDisplay(38))
                .foregroundStyle(Color.wakeButter)

            ZStack {
                WakePixelShape(cut: 32)
                    .fill(Color.wakePanelWarm)
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .overlay {
                        WakePixelShape(cut: 32)
                            .stroke(Color.wakeBorder, lineWidth: 1)
                    }

                Button {
                    catches += 1

                    withAnimation(.snappy(duration: 0.18)) {
                        currentOffset = positions.randomElement() ?? .zero
                    }

                    if catches >= 10 {
                        appState.completeWakeSession()
                        onComplete()
                    }
                } label: {
                    Text("TAP!")
                        .font(.wakeHeadline(24))
                        .foregroundStyle(Color.black)
                        .frame(width: 110, height: 110)
                        .background {
                            Circle().fill(Color.wakeButter)
                        }
                        .shadow(color: Color.wakeButter.opacity(0.4), radius: 22)
                }
                .buttonStyle(.plain)
                .offset(currentOffset)
            }

            WakeMissionProgressBar(progress: CGFloat(catches) / 10, tint: .wakeButter)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct VoiceRecordView: View {
    @EnvironmentObject private var appState: AppState

    @State private var isRecording = false
    @State private var seconds = 0
    @State private var showsMicrophonePrompt = false
    @State private var isRequestingPermission = false
    @State private var showsPermissionWarning = false

    let onSave: () -> Void

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var sleepyFriends: [String] {
        appState.activeGroup?.members
            .filter { !$0.isCurrentUser && $0.status != .awake }
            .map(\.name) ?? []
    }

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "친구 깨우기")

            WakeSectionHeader(
                eyebrow: "VOICE",
                title: "음성 메시지를 남기세요",
                subtitle: sleepyFriends.isEmpty ? "지금은 모든 친구가 기상을 완료했어요." : sleepyFriends.joined(separator: ", ")
            )

            if showsPermissionWarning {
                WakePanel(fill: .wakePanelWarm, accent: .wakeTomato) {
                    Text("마이크 권한이 필요합니다.")
                        .font(.wakeBody(size: 15, weight: .bold))
                        .foregroundStyle(Color.wakeInk)
                }
            }

            Button {
                handleRecordButtonTap()
            } label: {
                VStack(spacing: 18) {
                    ZStack {
                        Circle()
                            .fill(isRecording ? Color.wakeTomato : Color.wakeButter)
                            .frame(width: 150, height: 150)
                            .shadow(color: (isRecording ? Color.wakeTomato : Color.wakeButter).opacity(0.3), radius: 24)

                        Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundStyle(Color.black)
                    }

                    Text(isRecording ? "REC \(seconds)초 / 15초" : "길게 눌러 녹음 시작")
                        .font(.wakeBody(size: 18, weight: .bold))
                        .foregroundStyle(Color.wakeInk)
                }
                .frame(maxWidth: .infinity, minHeight: 340)
                .background {
                    WakePixelShape(cut: 32)
                        .fill(Color.wakePanel)
                }
                .overlay {
                    WakePixelShape(cut: 32)
                        .stroke(isRecording ? Color.wakeTomato.opacity(0.7) : Color.wakeBorder, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(
                    title: "보내기",
                    isEnabled: seconds > 0 && !isRecording
                ) {
                    appState.saveRecordedVoiceNote(durationSeconds: seconds)
                    onSave()
                }
            }
        }
        .sheet(isPresented: $showsMicrophonePrompt) {
            MicrophonePermissionSheet(
                isProcessing: isRequestingPermission
            ) {
                Task {
                    isRequestingPermission = true
                    let granted = await appState.requestMicrophonePermission()
                    isRequestingPermission = false
                    showsMicrophonePrompt = false
                    showsPermissionWarning = !granted

                    if granted {
                        startRecording()
                    }
                }
            }
            .presentationDetents([.height(340)])
        }
        .onReceive(timer) { _ in
            guard isRecording else { return }
            if seconds < 15 {
                seconds += 1
            } else {
                isRecording = false
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func handleRecordButtonTap() {
        if isRecording {
            isRecording = false
            return
        }

        if appState.microphonePermissionState == .authorized {
            startRecording()
        } else {
            showsMicrophonePrompt = true
        }
    }

    private func startRecording() {
        seconds = 0
        isRecording = true
        showsPermissionWarning = false
    }
}

struct VoiceInboxView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    let primaryTitle: String
    var dismissOnPrimaryAction = false
    let onPrimaryAction: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "친구 음성")

            if let note = appState.latestVoiceNote {
                WakePanel(fill: .wakePanelWarm, accent: .wakePlum) {
                    WakeTape(text: note.senderName.uppercased(), fill: .wakePanel, ink: .wakePlum)

                    Text(note.summary)
                        .font(.wakeHeadline(30))
                        .foregroundStyle(Color.wakeInk)

                    HStack(spacing: 8) {
                        WakeTape(text: "\(note.durationSeconds)초", fill: .wakeSky, ink: .black)

                        if !note.recipients.isEmpty {
                            WakeTape(text: note.recipients.joined(separator: ", "), fill: .wakePanel, ink: .wakeInkSoft)
                        }
                    }
                }
            } else {
                WakePanel(fill: .wakePanel, accent: .wakeSky) {
                    WakeSectionHeader(
                        eyebrow: "VOICE",
                        title: "도착한 음성이 없어요",
                        subtitle: "새 메시지가 오면 이 화면에서 바로 확인할 수 있어요."
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(title: primaryTitle) {
                    if dismissOnPrimaryAction {
                        dismiss()
                    } else {
                        onPrimaryAction()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

struct WakeCompleteView: View {
    @EnvironmentObject private var appState: AppState

    let onBackToBoard: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            VStack(spacing: 22) {
                Spacer(minLength: 18)

                ZStack {
                    Circle()
                        .fill(Color.wakeButter)
                        .frame(width: 150, height: 150)
                        .shadow(color: Color.wakeButter.opacity(0.32), radius: 26)

                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 56, weight: .bold))
                        .foregroundStyle(Color.black)
                }

                Text("기상 완료!")
                    .font(.wakeHeadline(44))
                    .foregroundStyle(Color.wakeInk)

                Text("오늘도 상쾌한 아침을 시작하세요!")
                    .font(.wakeBody(size: 18, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)

                WakePanel(fill: .wakePanelWarm, accent: .wakePlum) {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.wakePlum)
                            .padding(.top, 4)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("친구에게 목소리 전하기")
                                .font(.wakeBody(size: 18, weight: .bold))
                                .foregroundStyle(Color.wakeInk)

                            Text("아직 일어나는 중인 친구에게 응원 메시지를 남겨보세요.")
                                .font(.wakeBody(size: 14, weight: .medium))
                                .foregroundStyle(Color.wakeInkSoft)
                        }
                    }
                }

                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity)
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(title: "메인으로 돌아가기") {
                    onBackToBoard()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MicrophonePermissionSheet: View {
    let isProcessing: Bool
    let action: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                WakeSectionHeader(
                    eyebrow: "PERMISSION",
                    title: "마이크를 허용할까요?",
                    subtitle: "음성 메시지를 녹음하려면 마이크 권한이 필요합니다."
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(
                    title: isProcessing ? "확인 중..." : "마이크 허용",
                    isEnabled: !isProcessing,
                    action: action
                )
            }
        }
    }
}

private struct WakeMissionShell<Content: View>: View {
    let title: String
    let accent: Color
    @ViewBuilder var content: () -> Content

    var body: some View {
        WakeScene(bottomInset: 24) {
            VStack(spacing: 22) {
                Spacer(minLength: 20)

                HStack(alignment: .center, spacing: 10) {
                    WakeMascotSticker(kind: leadingMascot, size: 46)

                    Text("오늘의 기상 미션")
                        .font(.wakeHeadline(40))
                        .foregroundStyle(Color.wakeInk)
                        .multilineTextAlignment(.center)

                    WakeMascotSticker(kind: trailingMascot, size: 46)
                }

                WakeTape(text: title, fill: .wakePanelWarm, ink: accent)

                content()

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var leadingMascot: WakeMascotKind {
        if title == "100번 연타" {
            return .bird
        }

        return title == "버튼 잡기" ? .wingBird : .sun
    }

    private var trailingMascot: WakeMascotKind {
        if title == "100번 연타" {
            return .wingBird
        }

        return title == "버튼 잡기" ? .cat : .sleepMoon
    }
}

private struct WakeMissionProgressBar: View {
    let progress: CGFloat
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.wakePanelWarm)

                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * min(max(progress, 0), 1))
                    .shadow(color: tint.opacity(0.35), radius: 12)
            }
        }
        .frame(height: 12)
    }
}

private struct WakeLiquidCircle: View {
    let progress: CGFloat
    let tint: Color
    let label: String

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.wakePanelWarm)

            GeometryReader { proxy in
                let height = proxy.size.height * min(max(progress, 0), 1)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    Rectangle()
                        .fill(tint.opacity(0.24))
                        .frame(height: height)
                }
                .clipShape(Circle())
            }

            Circle()
                .stroke(tint, lineWidth: 6)

            Text(label)
                .font(.wakeHeadline(24))
                .foregroundStyle(tint)
        }
    }
}
