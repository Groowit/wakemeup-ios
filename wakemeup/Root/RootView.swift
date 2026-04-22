import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            switch appState.rootDestination {
            case .onboarding:
                OnboardingFlowView()
                    .transition(.opacity)
            case .auth:
                AuthEntryView()
                    .transition(.opacity)
            case .main:
                MainTabContainerView()
                    .transition(.opacity)
            }
        }
        .animation(.snappy(duration: 0.35), value: appState.rootDestination)
    }
}
