import SwiftUI
import UIKit

enum InviteShareMode {
    case pendingGroup
    case activeGroup
}

struct InviteShareView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var copied = false

    let mode: InviteShareMode
    let onNext: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "초대 공유")

            if mode == .pendingGroup {
                WakeStepIndicator(current: 3, total: 4)
            }

            WakeSectionHeader(
                eyebrow: "INVITE",
                title: "친구를 초대하세요",
                subtitle: "코드나 링크로 바로 그룹에 참여할 수 있어요."
            )

            WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                if let groupName {
                    Text(groupName)
                        .font(.wakeHeadline(28))
                        .foregroundStyle(Color.wakeInk)
                }

                Text(inviteCode)
                    .font(.wakeDisplay(40))
                    .tracking(4)
                    .foregroundStyle(Color.wakeInk)

                if copied {
                    WakeTape(text: "코드가 복사되었습니다", fill: .wakeButter, ink: .black)
                }
            }

            HStack(spacing: 12) {
                Button {
                    UIPasteboard.general.string = inviteCode
                    copied = true
                } label: {
                    WakeQuickActionTile(
                        badge: "COPY",
                        title: "코드 복사",
                        subtitle: "초대 코드를 복사합니다.",
                        tint: .wakeMint.opacity(0.4)
                    )
                }
                .buttonStyle(.plain)

                ShareLink(item: shareText) {
                    WakeQuickActionTile(
                        badge: "SHARE",
                        title: "링크 공유",
                        subtitle: "메신저로 바로 보냅니다.",
                        tint: .wakeButter
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(title: mode == .pendingGroup ? "내 기상 시간 설정" : "확인") {
                    if mode == .pendingGroup {
                        onNext()
                    } else {
                        dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var inviteCode: String {
        switch mode {
        case .pendingGroup:
            return appState.pendingGroupDraft?.inviteCode ?? "------"
        case .activeGroup:
            return appState.activeGroup?.inviteCode ?? "------"
        }
    }

    private var groupName: String? {
        switch mode {
        case .pendingGroup:
            return appState.pendingGroupDraft?.resolvedName
        case .activeGroup:
            return appState.activeGroup?.name
        }
    }

    private var shareText: String {
        "깨워줘 그룹 초대 코드: \(inviteCode)"
    }
}
