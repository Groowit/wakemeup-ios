import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var currentPage = 0

    var body: some View {
        WakeScene(bottomInset: 24) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Spacer()

                    Button("건너뛰기") {
                        appState.skipToAuth()
                    }
                    .font(.wakeBody(size: 14, weight: .semibold))
                    .foregroundStyle(Color.wakeInkSoft)
                }

                TabView(selection: $currentPage) {
                    ForEach(Array(appState.onboardingPages.enumerated()), id: \.element.id) { index, page in
                        OnboardingSlide(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 560)

                HStack(spacing: 8) {
                    Spacer()
                    ForEach(appState.onboardingPages.indices, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color.wakeButter : Color.wakeBorder)
                            .frame(width: index == currentPage ? 30 : 10, height: 8)
                            .shadow(color: index == currentPage ? Color.wakeButter.opacity(0.3) : .clear, radius: 10)
                    }
                    Spacer()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            WakeBottomBar {
                WakeButton(
                    title: currentPage == appState.onboardingPages.count - 1 ? "시작하기" : "다음",
                    action: advancePage
                )
            }
        }
    }

    private func advancePage() {
        if currentPage == appState.onboardingPages.count - 1 {
            appState.finishOnboarding()
            return
        }

        withAnimation(.snappy(duration: 0.35)) {
            currentPage += 1
        }
    }
}

private struct OnboardingSlide: View {
    let page: OnboardingPage
    let index: Int

    var body: some View {
        VStack(spacing: 26) {
            Spacer(minLength: 12)

            ZStack {
                WakeMascotSticker(
                    kind: index == 0 ? .sun : index == 1 ? .bird : .wingBird,
                    size: 58
                )
                .offset(x: -104, y: -58)

                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(Color.wakePanel)
                    .frame(width: 180, height: 180)
                    .shadow(color: accent.opacity(0.18), radius: 24)

                WakeOnboardingSticker(index: index)

                WakeMascotSticker(
                    kind: index == 2 ? .sleepMoon : .cat,
                    size: index == 2 ? 62 : 54,
                    flipHorizontally: index == 1
                )
                .offset(x: 98, y: 68)
            }

            VStack(spacing: 12) {
                Text("깨워줘")
                    .font(.wakeHeadline(34))
                    .foregroundStyle(Color.wakeInk)

                Text(page.title)
                    .font(.wakeHeadline(32))
                    .foregroundStyle(Color.wakeInk)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.wakeBody(size: 18, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
                    .multilineTextAlignment(.center)
            }

            Spacer(minLength: 20)

            Text(index == appStateIndexLast ? "이미 계정이 있으신가요? 로그인" : "함께 일어나는 가장 확실한 방법")
                .font(.wakeBody(size: 15, weight: .semibold))
                .foregroundStyle(index == appStateIndexLast ? Color.wakeInkSoft : accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 10)
    }

    private var accent: Color {
        switch index {
        case 0:
            return .wakeButter
        case 1:
            return .wakeSky
        default:
            return .wakePlum
        }
    }

    private var appStateIndexLast: Int {
        2
    }
}
