import SwiftUI

enum MissionPickerMode {
    case groupCreation
    case groupSettings
}

struct MissionPickerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMissionKind: MissionKind

    let mode: MissionPickerMode
    let onSubmit: () -> Void

    init(
        mode: MissionPickerMode,
        initialMissionKind: MissionKind,
        onSubmit: @escaping () -> Void
    ) {
        self.mode = mode
        self.onSubmit = onSubmit
        _selectedMissionKind = State(initialValue: initialMissionKind)
    }

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "미션 선택")

            if mode == .groupCreation {
                WakeStepIndicator(current: 2, total: 4)
            }

            WakeSectionHeader(
                eyebrow: "MISSION",
                title: "기상 미션 선택",
                subtitle: "그룹은 한 번에 하나의 미션으로 진행됩니다."
            )

            VStack(spacing: 14) {
                ForEach(appState.availableMissions) { mission in
                    Button {
                        selectedMissionKind = mission.kind
                    } label: {
                        WakePanel(
                            fill: .wakePanel,
                            accent: mission.kind.tint
                        ) {
                            HStack(alignment: .top, spacing: 16) {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(mission.kind.tint.opacity(0.15))
                                    .frame(width: 62, height: 62)
                                    .overlay {
                                        Text(mission.kind.marker)
                                            .font(.wakePixel(18))
                                            .foregroundStyle(mission.kind.tint)
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(mission.kind.tint.opacity(0.35), lineWidth: 1)
                                    }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(mission.title)
                                            .font(.wakeHeadline(24))
                                            .foregroundStyle(Color.wakeInk)

                                        Spacer()

                                        if selectedMissionKind == mission.kind {
                                            WakeTape(text: "선택됨", fill: .wakeButter, ink: .black)
                                        }
                                    }

                                    Text(mission.detail)
                                        .font(.wakeBody(size: 15))
                                        .foregroundStyle(Color.wakeInkSoft)

                                    Text(mission.sampleText)
                                        .font(.wakePixel(11))
                                        .foregroundStyle(mission.kind.tint.opacity(0.88))
                                }
                            }
                        }
                        .overlay {
                            WakePixelShape(cut: 28)
                                .stroke(
                                    selectedMissionKind == mission.kind ? mission.kind.tint.opacity(0.7) : Color.wakeBorder,
                                    lineWidth: 1
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(title: mode == .groupCreation ? "다음" : "저장") {
                    let mission = appState.availableMissions.first(where: { $0.kind == selectedMissionKind }) ?? appState.selectedMission

                    if mode == .groupCreation {
                        appState.selectMission(mission)
                        onSubmit()
                    } else {
                        appState.applyMissionToActiveGroup(mission)
                        dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
}
