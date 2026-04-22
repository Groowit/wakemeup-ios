import SwiftUI
import UIKit

struct JoinGroupView: View {
    @EnvironmentObject private var appState: AppState
    @FocusState private var isCodeFieldFocused: Bool

    @State private var inviteCode = ""

    let onNext: () -> Void

    var body: some View {
        WakeScene(bottomInset: 24) {
            WakeTopBar(title: "그룹 참여하기")

            VStack(alignment: .center, spacing: 16) {
                Text("초대 코드를\n입력하세요")
                    .font(.wakeHeadline(40))
                    .foregroundStyle(Color.wakeInk)
                    .multilineTextAlignment(.center)

                Text("친구에게 받은 6자리 코드를 입력해 주세요.")
                    .font(.wakeBody(size: 17, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 18)

            ZStack {
                WakePanel(fill: .wakePanelWarm, accent: .wakeButter) {
                    Text(inviteCodeDisplay)
                        .font(.wakeDisplay(28))
                        .tracking(6)
                        .foregroundStyle(inviteCode.isEmpty ? Color.wakeInkSoft.opacity(0.75) : Color.wakeInk)
                        .frame(maxWidth: .infinity, minHeight: 92)
                        .multilineTextAlignment(.center)
                }

                TextField("", text: $inviteCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .keyboardType(.asciiCapable)
                    .focused($isCodeFieldFocused)
                    .foregroundStyle(.clear)
                    .accentColor(.clear)
                    .onChange(of: inviteCode) { _, newValue in
                        inviteCode = filteredInviteCode(from: newValue)
                    }
                    .padding(24)
            }
            .onTapGesture {
                isCodeFieldFocused = true
            }

            VStack(spacing: 14) {
                WakeButton(
                    title: "그룹 참여하기",
                    isEnabled: inviteCode.count == 6
                ) {
                    guard inviteCode.count == 6 else { return }
                    appState.prepareJoinGroup(inviteCode: inviteCode)
                    onNext()
                }

                if UIPasteboard.general.hasStrings {
                    Button {
                        inviteCode = filteredInviteCode(from: UIPasteboard.general.string ?? "")
                    } label: {
                        Text("붙여넣기")
                            .font(.wakeBody(size: 16, weight: .bold))
                            .foregroundStyle(Color.wakeInkSoft)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 52)
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
            .padding(.top, 8)

            Spacer(minLength: 40)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            isCodeFieldFocused = true
        }
    }

    private var inviteCodeDisplay: String {
        inviteCode.isEmpty ? "ABCDEF" : inviteCode
    }

    private func filteredInviteCode(from value: String) -> String {
        let allowed = value.uppercased().filter { $0.isLetter || $0.isNumber }
        return String(allowed.prefix(6))
    }
}
