//
//  wakemeupTests.swift
//  wakemeupTests
//
//  Created by 김예영 on 4/16/26.
//

import Testing
@testable import wakemeup

@MainActor
struct AppStateTests {

    @Test func rootFlowMovesFromOnboardingToAuthToMain() async throws {
        let state = AppState()

        #expect(state.rootDestination == .onboarding)

        state.finishOnboarding()
        #expect(state.rootDestination == .auth)

        state.signInDemo(nickname: "모닝버디")
        #expect(state.rootDestination == .main)
        #expect(state.currentUser.displayName == "모닝버디")
    }

    @Test func mockGroupLifecycleStaysPredictable() async throws {
        let state = AppState(
            hasSeenOnboarding: true,
            isAuthenticated: true
        )

        #expect(state.activeGroup == nil)

        state.activateMockGroup(
            named: "아침 러너즈",
            memberCount: 3
        )

        #expect(state.activeGroup?.name == "아침 러너즈")
        #expect(state.activeGroup?.members.count == 3)

        state.clearActiveGroup()
        #expect(state.activeGroup == nil)
    }
}
