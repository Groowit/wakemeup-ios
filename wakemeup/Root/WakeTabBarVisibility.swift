import SwiftUI

private struct WakeTabBarHiddenPreferenceKey: PreferenceKey {
    static var defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func wakeTabBarHidden(_ hidden: Bool = true) -> some View {
        preference(key: WakeTabBarHiddenPreferenceKey.self, value: hidden)
    }

    func onWakeTabBarHiddenPreferenceChange(_ action: @escaping (Bool) -> Void) -> some View {
        onPreferenceChange(WakeTabBarHiddenPreferenceKey.self, perform: action)
    }
}
