import SwiftUI

enum WakeSetupMode: Hashable {
    case createGroup
    case joinGroup
    case editExisting
}

struct WakeSetupView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var showsNotificationPrompt = false
    @State private var isRequestingPermission = false

    let mode: WakeSetupMode
    let onComplete: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "내 기상 시간 설정")

            if mode != .editExisting {
                WakeStepIndicator(current: 4, total: 4)
            }

            WakeSectionHeader(
                eyebrow: "WAKE TIME",
                title: mode == .editExisting ? "기상 일정을 조정하세요" : "내 기상 일정을 정하세요",
                subtitle: "알림이 울릴 시간과 반복 요일을 설정합니다."
            )

            WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                Text("기상 시각")
                    .font(.wakePixel(12))
                    .foregroundStyle(Color.wakeInkSoft)

                DatePicker(
                    "기상 시각",
                    selection: $appState.wakeTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
            }

            WakePanel(fill: .wakePanel, accent: .wakeSky) {
                Text("반복 요일")
                    .font(.wakePixel(12))
                    .foregroundStyle(Color.wakeInkSoft)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(WakeWeekday.allCases) { day in
                        Button {
                            appState.toggleWakeDay(day)
                        } label: {
                            WakeChoiceChip(
                                title: day.rawValue,
                                isSelected: appState.wakeDays.contains(day),
                                tint: day == .sat || day == .sun ? Color.wakeTomato.opacity(0.18) : .wakeMint.opacity(0.42)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            if appState.selectedMissionKind == .typing {
                WakePanel(fill: .wakePanel, accent: .wakeMint) {
                    WakeNotebookField(
                        title: "타자치기 문장",
                        placeholder: "예: 나는 오늘 7시 25분 전에 책상 앞에 앉아 있다.",
                        text: $appState.wakePhrase,
                        helper: "미션 시작 시 그대로 입력해야 하는 문장입니다."
                    )
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(title: mode == .editExisting ? "저장" : "완료") {
                    if appState.notificationPermissionState == .notRequested {
                        showsNotificationPrompt = true
                    } else {
                        finalizeSetup()
                    }
                }
            }
        }
        .sheet(isPresented: $showsNotificationPrompt) {
            PermissionRequestSheet(
                title: "알림을 허용할까요?",
                message: "설정한 시간에 기상 플로우를 시작하려면 알림 권한이 필요합니다.",
                actionTitle: "알림 허용",
                isProcessing: isRequestingPermission
            ) {
                Task {
                    isRequestingPermission = true
                    _ = await appState.requestNotificationPermission()
                    isRequestingPermission = false
                    showsNotificationPrompt = false
                    finalizeSetup()
                }
            }
            .presentationDetents([.height(340)])
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private func finalizeSetup() {
        appState.saveWakeSchedule()

        if mode == .createGroup || mode == .joinGroup {
            appState.activateGroupFromPendingDraft()
            onComplete()
        } else {
            dismiss()
        }
    }
}

private struct PermissionRequestSheet: View {
    let title: String
    let message: String
    let actionTitle: String
    let isProcessing: Bool
    let action: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                WakeSectionHeader(
                    eyebrow: "PERMISSION",
                    title: title,
                    subtitle: message
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(
                    title: isProcessing ? "확인 중..." : actionTitle,
                    isEnabled: !isProcessing,
                    action: action
                )
            }
        }
    }
}
