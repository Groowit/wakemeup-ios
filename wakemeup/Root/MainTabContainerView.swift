import SwiftUI

struct MainTabContainerView: View {
    @EnvironmentObject private var appState: AppState
    @State private var isTabBarHidden = false

    private let items = [
        WakeTabItem(id: .groups, title: "홈", badge: "HOME", symbol: "house"),
        WakeTabItem(id: .history, title: "기록", badge: "LOG", symbol: "clock.arrow.circlepath"),
        WakeTabItem(id: .profile, title: "마이", badge: "ME", symbol: "person")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            currentContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onWakeTabBarHiddenPreferenceChange { isTabBarHidden = $0 }

            if !isTabBarHidden {
                WakeTabBar(items: items, selection: selectionBinding)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .animation(.snappy(duration: 0.22), value: isTabBarHidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }

    private var selectionBinding: Binding<AppState.MainTab> {
        Binding(
            get: { appState.selectedTab },
            set: { appState.selectedTab = $0 }
        )
    }

    @ViewBuilder
    private var currentContent: some View {
        switch appState.selectedTab {
        case .groups:
            GroupsHomeView()
        case .history:
            HistoryView()
        case .profile:
            ProfileView()
        }
    }
}
