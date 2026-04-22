import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            WakeScene {
                HStack(alignment: .top) {
                    HStack(spacing: 10) {
                        Text("마이페이지")
                            .font(.wakeHeadline(42))
                            .foregroundStyle(Color.wakeButter)

                        WakeMascotSticker(kind: .cat, size: 42)
                            .offset(y: -2)
                    }

                    Spacer()

                    Circle()
                        .fill(Color.wakePanelWarm)
                        .frame(width: 42, height: 42)
                        .overlay {
                            Image(systemName: "gearshape")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.wakeInkSoft)
                        }
                        .overlay {
                            Circle().stroke(Color.wakeBorder, lineWidth: 1)
                        }
                }

                VStack(spacing: 12) {
                    ZStack(alignment: .bottomTrailing) {
                        WakeMascotSticker(kind: .sleepMoon, size: 62)
                            .offset(x: 54, y: -44)

                        WakeAvatarStamp(
                            avatar: appState.currentUser.avatar,
                            size: 104,
                            fill: Color.wakePanelWarm
                        )

                        Circle()
                            .fill(Color.wakeButter)
                            .frame(width: 34, height: 34)
                            .overlay {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(Color.black)
                            }
                            .offset(x: 8, y: 2)
                    }

                    Text(appState.currentUser.displayName)
                        .font(.wakeHeadline(34))
                        .foregroundStyle(Color.wakeInk)

                    Text("\(appState.currentUser.currentStreakDays) DAYS ACTIVE")
                        .font(.wakePixel(14))
                        .foregroundStyle(Color.wakeInkSoft)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 8)

                VStack(spacing: 12) {
                    ProfileSettingRow(
                        icon: "bell",
                        title: "알림 설정",
                        status: appState.notificationPermissionState.title,
                        statusTint: appState.notificationPermissionState == .authorized ? .wakeButter : .wakeInkSoft
                    )

                    ProfileSettingRow(
                        icon: "mic",
                        title: "마이크 권한",
                        status: appState.microphonePermissionState.title,
                        statusTint: appState.microphonePermissionState == .authorized ? .wakeMint : .wakeInkSoft
                    )

                    ProfileSettingRow(
                        icon: "clock",
                        title: "알람 상세 설정",
                        status: appState.currentUser.preferredWakeTime,
                        statusTint: .wakeSky
                    )

                    ProfileSettingRow(
                        icon: "shield",
                        title: appState.activeGroup == nil ? "참여 그룹" : "참여 중인 그룹",
                        status: appState.activeGroup?.name ?? "없음",
                        statusTint: appState.activeGroup == nil ? .wakeInkSoft : .wakeButter
                    )
                }

                if appState.activeGroup != nil {
                    Button {
                        appState.clearActiveGroup()
                    } label: {
                        Text("현재 그룹 나가기")
                            .font(.wakeBody(size: 18, weight: .bold))
                            .foregroundStyle(Color.wakeInk)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 56)
                            .background {
                                WakePixelShape(cut: 24)
                                    .fill(Color.wakePanel)
                            }
                            .overlay {
                                WakePixelShape(cut: 24)
                                    .stroke(Color.wakeBorder, lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }

                Button {
                    appState.signOut()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .semibold))
                        Text("로그아웃")
                            .font(.wakeBody(size: 24, weight: .bold))
                    }
                    .foregroundStyle(Color.wakePlum)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct ProfileSettingRow: View {
    let icon: String
    let title: String
    let status: String
    let statusTint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.wakePanelWarm)
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.wakeInkSoft)
            }

            Text(title)
                .font(.wakeBody(size: 18, weight: .bold))
                .foregroundStyle(Color.wakeInk)

            Spacer()

            Text(status)
                .font(.wakeBody(size: 14, weight: .bold))
                .foregroundStyle(statusTint)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(Color.wakeInkSoft.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background {
            WakePixelShape(cut: 24)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 24)
                .stroke(Color.wakeBorder, lineWidth: 1)
        }
    }
}
