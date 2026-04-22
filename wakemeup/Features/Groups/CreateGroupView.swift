import SwiftUI

struct CreateGroupView: View {
    @EnvironmentObject private var appState: AppState

    @State private var groupName = ""
    @State private var memberCount = 3

    let onNext: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "새 그룹 만들기")
            WakeStepIndicator(current: 1, total: 4)

            WakeSectionHeader(
                eyebrow: "GROUP",
                title: "그룹 이름을 정하세요",
                subtitle: "친구들이 한눈에 알아볼 수 있는 이름이면 충분해요."
            )

            WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                WakeNotebookField(
                    title: "그룹 이름",
                    placeholder: "예: 아침 루틴 팀",
                    text: $groupName,
                    helper: "친구들이 바로 알아볼 수 있는 이름으로 정해 주세요."
                )
            }

            WakePanel(fill: .wakePanel, accent: .wakeSky) {
                Text("예상 인원")
                    .font(.wakePixel(12))
                    .foregroundStyle(Color.wakeInkSoft)

                HStack(spacing: 10) {
                    ForEach([2, 3, 4], id: \.self) { count in
                        Button {
                            memberCount = count
                        } label: {
                            WakeChoiceChip(
                                title: "\(count)명",
                                subtitle: count == 2 ? "가볍게 시작" : count == 3 ? "가장 일반적" : "최대 인원",
                                isSelected: memberCount == count,
                                tint: count == 4 ? Color.wakeTomato.opacity(0.2) : .wakeButter
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(
                    title: "다음",
                    isEnabled: trimmedGroupName != nil
                ) {
                    guard let trimmedGroupName else { return }
                    appState.updatePendingGroup(name: trimmedGroupName, memberCount: memberCount)
                    onNext()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if appState.pendingGroupDraft?.source != .create {
                appState.beginGroupCreation()
            }
            groupName = appState.pendingGroupDraft?.name ?? ""
            memberCount = appState.pendingGroupDraft?.memberCount ?? 3
        }
    }

    private var trimmedGroupName: String? {
        let trimmed = groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
