import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var appState: AppState

    private var recentRecords: [HistoryDay] {
        let days = appState.historySummary.days.filter { $0.isCurrentMonth && !$0.label.isEmpty }
        return Array(days.suffix(6).reversed())
    }

    private var monthLabel: String {
        appState.historySummary.monthTitle
            .components(separatedBy: " ")
            .last ?? appState.historySummary.monthTitle
    }

    var body: some View {
        NavigationStack {
            WakeScene {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("기상 기록")
                                .font(.wakeHeadline(42))
                                .foregroundStyle(Color.wakeButter)

                            Text("\(appState.currentUser.preferredWakeTime) 미라클 모닝 ☀︎")
                                .font(.wakeBody(size: 18, weight: .medium))
                                .foregroundStyle(Color.wakeInkSoft)
                        }

                        Spacer()

                        WakeMascotSticker(kind: .wingBird, size: 64)
                    }

                    HStack(spacing: 14) {
                        StatBlock(
                            icon: "arrow.up.right",
                            title: "주간 성공률",
                            value: "\(appState.historySummary.recentSuccessRate)%",
                            accent: .wakeButter
                        )

                        StatBlock(
                            icon: "calendar",
                            title: "연속 기상",
                            value: "\(appState.currentUser.currentStreakDays)일",
                            accent: .wakeSky
                        )
                    }

                    VStack(alignment: .leading, spacing: 14) {
                        Text("상세 기록")
                            .font(.wakeHeadline(30))
                            .foregroundStyle(Color.wakeInk)

                        ForEach(Array(recentRecords.enumerated()), id: \.offset) { index, day in
                            HistoryRecordCard(
                                title: "\(monthLabel) \(day.label)일",
                                statusText: day.isSuccessful ? "기상 성공" : "기상 실패",
                                timeText: day.isSuccessful ? appState.currentUser.preferredWakeTime : "-",
                                isSuccess: day.isSuccessful,
                                isHighlighted: index == 0
                            )
                        }
                    }

                    WakePanel(fill: .wakePanel, accent: .wakePlum) {
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(appState.historySummary.insightTitle)
                                    .font(.wakeBody(size: 18, weight: .bold))
                                    .foregroundStyle(Color.wakeInk)

                                Text(appState.historySummary.insightMessage)
                                    .font(.wakeBody(size: 15, weight: .medium))
                                    .foregroundStyle(Color.wakeInkSoft)
                            }

                            Spacer()

                            WakeMascotSticker(kind: .sleepMoon, size: 52)
                        }
                    }
                }
            }
        }
    }
}

private struct StatBlock: View {
    let icon: String
    let title: String
    let value: String
    let accent: Color

    var body: some View {
        WakePanel(fill: .wakePanelWarm, accent: accent) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(accent)

            Text(title)
                .font(.wakeBody(size: 14, weight: .semibold))
                .foregroundStyle(Color.wakeInkSoft)

            Text(value)
                .font(.wakeHeadline(32))
                .foregroundStyle(Color.wakeInk)
        }
    }
}

private struct HistoryRecordCard: View {
    let title: String
    let statusText: String
    let timeText: String
    let isSuccess: Bool
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(statusTint.opacity(0.16))
                    .frame(width: 54, height: 54)

                Image(systemName: isSuccess ? "checkmark.circle" : "xmark.circle")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(statusTint)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.wakeBody(size: 20, weight: .bold))
                    .foregroundStyle(Color.wakeInk)

                Text(statusText)
                    .font(.wakeBody(size: 15, weight: .semibold))
                    .foregroundStyle(statusTint)
            }

            Spacer()

            Text(timeText)
                .font(.wakeBody(size: 18, weight: .bold))
                .foregroundStyle(Color.wakeInkSoft)
        }
        .padding(16)
        .background {
            WakePixelShape(cut: 24)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 24)
                .stroke(isHighlighted ? statusTint.opacity(0.42) : Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: isHighlighted ? statusTint.opacity(0.14) : .clear, radius: 14)
    }

    private var statusTint: Color {
        isSuccess ? .wakeButter : .wakePlum
    }
}
