import SwiftUI

struct AuthEntryView: View {
    @EnvironmentObject private var appState: AppState
    @FocusState private var isNicknameFocused: Bool

    var body: some View {
        NavigationStack {
            WakeScene(bottomInset: 24) {
                HStack {
                    if appState.authStep == .nickname {
                        Button {
                            appState.retreatAuthStep()
                        } label: {
                            WakeBackGlyph()
                                .frame(width: AppTheme.Size.topBarButton, height: AppTheme.Size.topBarButton)
                                .background {
                                    WakePixelShape(cut: 18)
                                        .fill(Color.wakePanelWarm)
                                }
                                .overlay {
                                    WakePixelShape(cut: 18)
                                        .stroke(Color.wakeBorder, lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                    } else {
                        Color.clear.frame(width: AppTheme.Size.topBarButton, height: AppTheme.Size.topBarButton)
                    }

                    Spacer()
                }

                if appState.authStep == .avatar {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("반가워요!")
                                .font(.wakeHeadline(42))
                                .foregroundStyle(Color.wakeInk)

                            Text("함께 일어날 캐릭터를 먼저 선택해 주세요.")
                                .font(.wakeBody(size: 18, weight: .medium))
                                .foregroundStyle(Color.wakeInkSoft)
                        }

                        Spacer()

                        WakeMascotSticker(kind: .bird, size: 58)
                    }

                    WakeAvatarCarousel(
                        avatars: AvatarSticker.allCases,
                        selection: Binding(
                            get: { appState.selectedAvatar },
                            set: { appState.selectAuthAvatar($0) }
                        )
                    )

                    WakePanel(fill: .wakePanel, accent: appState.selectedAvatar.accentTint) {
                        Text(appState.selectedAvatar.title)
                            .font(.wakeHeadline(26))
                            .foregroundStyle(Color.wakeInk)

                        Text(appState.selectedAvatar.note)
                            .font(.wakeBody(size: 16, weight: .medium))
                            .foregroundStyle(Color.wakeInkSoft)
                    }
                } else {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("닉네임을 설정하세요")
                                .font(.wakeHeadline(42))
                                .foregroundStyle(Color.wakeInk)

                            Text("그룹에서 보여질 이름으로 사용됩니다.")
                                .font(.wakeBody(size: 18, weight: .medium))
                                .foregroundStyle(Color.wakeInkSoft)
                        }

                        Spacer()

                        WakeMascotSticker(kind: .cat, size: 58)
                    }

                    WakePanel(fill: .wakePanel, accent: appState.selectedAvatar.accentTint) {
                        HStack(spacing: 16) {
                            WakeAvatarStamp(
                                avatar: appState.selectedAvatar,
                                size: 86,
                                fill: appState.selectedAvatar.cardTint
                            )

                            VStack(alignment: .leading, spacing: 6) {
                                Text(appState.selectedAvatar.title)
                                    .font(.wakeHeadline(24))
                                    .foregroundStyle(Color.wakeInk)

                                Text(appState.selectedAvatar.note)
                                    .font(.wakeBody(size: 15, weight: .medium))
                                    .foregroundStyle(Color.wakeInkSoft)
                            }
                        }
                    }

                    WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("닉네임")
                                .font(.wakePixel(11))
                                .foregroundStyle(Color.wakeInkSoft)

                            TextField(
                                "",
                                text: $appState.authNickname,
                                prompt: Text("예: 예영").foregroundColor(Color.wakeInkSoft.opacity(0.55))
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .textContentType(.nickname)
                            .submitLabel(.done)
                            .focused($isNicknameFocused)
                            .font(.wakeBody(size: 18, weight: .semibold))
                            .foregroundStyle(Color.wakeInk)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background {
                                WakePixelShape(cut: 24)
                                    .fill(Color.wakePanel)
                            }
                            .overlay {
                                WakePixelShape(cut: 24)
                                    .stroke(
                                        appState.authNicknameValidation.isValid ? Color.wakeButter.opacity(0.8) : Color.wakeBorder,
                                        lineWidth: 1
                                    )
                            }
                            .onSubmit {
                                if appState.authNicknameValidation.isValid {
                                    appState.completeAuthentication()
                                }
                            }

                            HStack(spacing: 8) {
                                WakeTape(
                                    text: appState.authNicknameValidation.isValid ? "사용 가능" : "2-12자",
                                    fill: appState.authNicknameValidation.isValid ? .wakeButter : .wakePanel,
                                    ink: appState.authNicknameValidation.isValid ? .black : .wakeInkSoft
                                )

                                Text(appState.authNicknameValidation.message)
                                    .font(.wakeBody(size: 14, weight: .semibold))
                                    .foregroundStyle(appState.authNicknameValidation.isValid ? Color.wakeInk : Color.wakeInkSoft)
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                WakeBottomBar {
                    if appState.authStep == .avatar {
                        WakeButton(title: "다음") {
                            appState.advanceAuthStep()
                        }
                    } else {
                        WakeButton(
                            title: "시작하기",
                            isEnabled: appState.authNicknameValidation.isValid
                        ) {
                            appState.completeAuthentication()
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .onChange(of: appState.authStep) { _, newValue in
                isNicknameFocused = newValue == .nickname
            }
        }
    }
}
