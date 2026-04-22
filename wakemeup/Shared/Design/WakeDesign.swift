import SwiftUI

struct WakeScene<Content: View>: View {
    var showsScrollIndicators = false
    var bottomInset: CGFloat = 120
    @ViewBuilder var content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: showsScrollIndicators) {
                    VStack(alignment: .leading, spacing: AppTheme.Space.section) {
                        content()
                    }
                    .frame(
                        maxWidth: AppTheme.Size.panelWidth,
                        minHeight: max(proxy.size.height - 32, 0),
                        alignment: .topLeading
                    )
                    .padding(.horizontal, AppTheme.Space.pageX)
                    .padding(.top, AppTheme.Space.pageTop + 4)
                    .padding(.bottom, bottomInset)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
            }
        }
    }
}

struct WakeBottomBar<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(spacing: 12) {
            content()
        }
        .padding(.horizontal, AppTheme.Space.pageX)
        .padding(.top, 18)
        .padding(.bottom, 10)
        .background {
            LinearGradient(
                colors: [
                    Color.wakePaper.opacity(0),
                    Color.wakePaper.opacity(0.84),
                    Color.wakePaper
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }
}

struct WakeStepIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 10) {
            WakeTape(
                text: "STEP \(current)/\(total)",
                fill: Color.wakePanelWarm,
                ink: .wakeButter
            )

            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < current ? Color.wakeButter : Color.wakeBorder)
                        .frame(width: index + 1 == current ? 30 : 10, height: 8)
                        .shadow(color: index < current ? Color.wakeButter.opacity(0.32) : .clear, radius: 10)
                }
            }
        }
    }
}

struct WakePanel<Content: View>: View {
    var fill: Color = .wakePanel
    var stroke: Color = .wakeBorder
    var padding: CGFloat = AppTheme.Space.panelPadding
    var accent: Color? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        let shape = WakePixelShape(cut: AppTheme.Corner.panel)
        let accentColor = accent ?? stroke

        VStack(alignment: .leading, spacing: AppTheme.Space.stack) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            shape
                .fill(fill)
                .overlay {
                    shape
                        .stroke(stroke.opacity(0.95), lineWidth: AppTheme.Border.pixel)
                }
                .overlay {
                    shape
                        .stroke(accentColor.opacity(accent == nil ? 0.12 : 0.38), lineWidth: 1)
                        .blur(radius: accent == nil ? 0 : 1.2)
                }
                .overlay(alignment: .topTrailing) {
                    if let accent {
                        Circle()
                            .fill(accent)
                            .frame(width: 8, height: 8)
                            .padding(16)
                            .shadow(color: accent.opacity(0.9), radius: 12)
                    }
                }
        }
        .shadow(color: Color.black.opacity(0.34), radius: 22, y: 12)
        .shadow(color: accentColor.opacity(accent == nil ? 0.05 : 0.16), radius: 16, y: 0)
    }
}

struct WakeSectionHeader: View {
    let eyebrow: String?
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let eyebrow {
                Text(eyebrow)
                    .font(.wakePixel(12))
                    .foregroundStyle(Color.wakeButter)
                    .tracking(1.2)
            }

            Text(title)
                .font(.wakeHeadline(40))
                .foregroundStyle(Color.wakeInk)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(.wakeBody(size: 16, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct WakeTape: View {
    let text: String
    var fill: Color = .wakeButter
    var ink: Color = .wakeInk

    var body: some View {
        Text(text)
            .font(.wakePixel(11))
            .foregroundStyle(ink)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background {
                WakePixelShape(cut: AppTheme.Corner.chip)
                    .fill(fill.opacity(0.16))
                    .overlay {
                        WakePixelShape(cut: AppTheme.Corner.chip)
                            .stroke(fill.opacity(0.55), lineWidth: 1)
                    }
            }
    }
}

struct WakeButton: View {
    enum Tone {
        case plum
        case paper
        case tomato
    }

    let title: String
    var caption: String? = nil
    var tone: Tone = .plum
    var isEnabled = true
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.wakeButton())
                    .multilineTextAlignment(.center)

                if let caption {
                    Text(caption)
                        .font(.wakeBody(size: 12, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: AppTheme.Size.tapTarget)
            .padding(.horizontal, 16)
        }
        .buttonStyle(WakeButtonStyle(tone: tone, isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct WakeButtonStyle: ButtonStyle {
    let tone: WakeButton.Tone
    let isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        let palette = palette

        return configuration.label
            .foregroundStyle(palette.foreground.opacity(isEnabled ? 1 : 0.55))
            .background {
                WakePixelShape(cut: AppTheme.Corner.field)
                    .fill(palette.fill.opacity(isEnabled ? 1 : 0.45))
                    .overlay {
                        WakePixelShape(cut: AppTheme.Corner.field)
                            .stroke(palette.stroke.opacity(isEnabled ? 1 : 0.45), lineWidth: 1)
                    }
            }
            .shadow(color: Color.black.opacity(0.28), radius: 14, y: 10)
            .shadow(color: palette.glow.opacity(isEnabled ? (configuration.isPressed ? 0.18 : 0.34) : 0), radius: configuration.isPressed ? 10 : 22)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var palette: (fill: Color, foreground: Color, stroke: Color, glow: Color) {
        switch tone {
        case .plum:
            return (.wakeButter, .black.opacity(0.9), .wakeButter.opacity(0.75), .wakeButter)
        case .paper:
            return (.wakePanelWarm, .wakeInk, .wakeBorder, .clear)
        case .tomato:
            return (.wakePanel, .wakePlum, .wakePlum.opacity(0.55), .wakePlum)
        }
    }
}

struct WakeNotebookField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var helper: String? = nil
    var autocapitalization: TextInputAutocapitalization = .never

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.wakePixel(11))
                .foregroundStyle(Color.wakeInkSoft)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundColor(Color.wakeInkSoft.opacity(0.6))
            )
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled()
            .focused($isFocused)
            .font(.wakeBody(size: 18, weight: .semibold))
            .foregroundStyle(Color.wakeInk)
            .padding(.horizontal, 18)
            .padding(.vertical, 18)
            .background {
                WakePixelShape(cut: AppTheme.Corner.field)
                    .fill(Color.wakePanelWarm)
                    .overlay {
                        WakePixelShape(cut: AppTheme.Corner.field)
                            .stroke(isFocused ? Color.wakeButter.opacity(0.8) : Color.wakeBorder, lineWidth: 1)
                    }
            }
            .shadow(color: isFocused ? Color.wakeButter.opacity(0.16) : .clear, radius: 14)

            if let helper {
                Text(helper)
                    .font(.wakeBody(size: 13, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
            }
        }
    }
}

struct WakeTopBar: View {
    let title: String
    var showsBack = true
    var trailing: AnyView? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            if showsBack {
                Button {
                    dismiss()
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

            if let trailing {
                trailing
            } else {
                Color.clear.frame(width: AppTheme.Size.topBarButton, height: AppTheme.Size.topBarButton)
            }
        }
        .overlay {
            Text(title)
                .font(.wakePixel(13))
                .foregroundStyle(Color.wakeInk)
        }
    }
}

struct WakeAvatarChip: View {
    let avatar: AvatarSticker
    var isSelected = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                WakeAvatarStamp(
                    avatar: avatar,
                    size: 72,
                    fill: isSelected ? avatar.cardTint.opacity(0.95) : Color.wakePanelWarm
                )

                Spacer()

                if isSelected {
                    WakeTape(text: "PICK", fill: avatar.accentTint, ink: .black)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(avatar.title)
                    .font(.wakeButton())
                    .foregroundStyle(Color.wakeInk)

                Text(avatar.note)
                    .font(.wakeBody(size: 14))
                    .foregroundStyle(Color.wakeInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            WakePixelShape(cut: 24)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 24)
                .stroke(isSelected ? avatar.frameTint : Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: isSelected ? avatar.frameTint.opacity(0.18) : .clear, radius: 16)
    }
}

struct WakeAvatarCarousel: View {
    let avatars: [AvatarSticker]
    @Binding var selection: AvatarSticker

    var body: some View {
        GeometryReader { proxy in
            let cardWidth = min(max(proxy.size.width - 96, 240), 300)
            let sideInset = max((proxy.size.width - cardWidth) / 2, 18)

            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(avatars) { avatar in
                        Button {
                            withAnimation(.snappy(duration: 0.25)) {
                                selection = avatar
                            }
                        } label: {
                            WakeAvatarCarouselCard(
                                avatar: avatar,
                                isSelected: selection == avatar
                            )
                            .frame(width: cardWidth)
                            .scaleEffect(selection == avatar ? 1 : 0.9)
                            .opacity(selection == avatar ? 1 : 0.72)
                        }
                        .buttonStyle(.plain)
                        .id(avatar)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
            .contentMargins(.horizontal, sideInset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: optionalSelection)
        }
        .frame(height: 330)
    }

    private var optionalSelection: Binding<AvatarSticker?> {
        Binding(
            get: { selection },
            set: { newValue in
                guard let newValue else { return }
                selection = newValue
            }
        )
    }
}

private struct WakeAvatarCarouselCard: View {
    let avatar: AvatarSticker
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Spacer()

                if isSelected {
                    WakeTape(text: "선택됨", fill: avatar.accentTint, ink: .black)
                }
            }

            Spacer(minLength: 0)

            WakeAvatarStamp(
                avatar: avatar,
                size: 154,
                fill: isSelected ? avatar.cardTint.opacity(0.95) : Color.wakePanelWarm
            )
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 8) {
                Text(avatar.title)
                    .font(.wakeHeadline(30))
                    .foregroundStyle(Color.wakeInk)

                Text(avatar.note)
                    .font(.wakeBody(size: 15))
                    .foregroundStyle(Color.wakeInkSoft)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            WakePixelShape(cut: 28)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 28)
                .stroke(isSelected ? avatar.frameTint : Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: isSelected ? avatar.frameTint.opacity(0.2) : .clear, radius: 18)
    }
}

struct WakeAvatarStamp: View {
    let avatar: AvatarSticker
    var size: CGFloat = 72
    var fill: Color? = nil

    var body: some View {
        let side = max(size, 44)
        let pixel = max(4, floor((side - 22) / 10))
        let backgroundFill = fill ?? avatar.cardTint

        ZStack {
            WakePixelShape(cut: 22)
                .fill(backgroundFill)

            Circle()
                .fill(avatar.accentTint.opacity(0.16))
                .blur(radius: 18)
                .padding(10)

            WakePixelSprite(avatar: avatar, pixel: pixel)
        }
        .frame(width: side, height: side)
        .overlay {
            WakePixelShape(cut: 22)
                .stroke(avatar.frameTint, lineWidth: 1)
        }
        .shadow(color: avatar.frameTint.opacity(0.18), radius: 12)
    }
}

private struct WakePixelSprite: View {
    let avatar: AvatarSticker
    let pixel: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(avatar.spriteRows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, token in
                        Rectangle()
                            .fill(avatar.spriteColor(for: token))
                            .frame(width: pixel, height: pixel)
                    }
                }
            }
        }
    }
}

struct WakeOnboardingSticker: View {
    let index: Int

    var body: some View {
        switch index {
        case 0:
            WakeAvatarStamp(avatar: .rabbit, size: 136, fill: Color.wakeButter.opacity(0.18))
        case 1:
            WakePixelBoardStamp()
        default:
            WakePixelMissionStamp()
        }
    }
}

struct WakeChoiceChip: View {
    let title: String
    var subtitle: String? = nil
    var isSelected = false
    var tint: Color = .wakeButter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.wakeBody(size: 16, weight: .bold))
                .foregroundStyle(Color.wakeInk)

            if let subtitle {
                Text(subtitle)
                    .font(.wakeBody(size: 12, weight: .medium))
                    .foregroundStyle(Color.wakeInkSoft)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            WakePixelShape(cut: 20)
                .fill(Color.wakePanelWarm)
        }
        .overlay {
            WakePixelShape(cut: 20)
                .stroke(isSelected ? tint.opacity(0.78) : Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: isSelected ? tint.opacity(0.18) : .clear, radius: 14)
    }
}

struct WakeQuickActionTile: View {
    let badge: String
    let title: String
    let subtitle: String
    var tint: Color = .wakeButter

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                WakeTape(text: badge, fill: tint, ink: .black)
                Spacer()
                Circle()
                    .fill(tint)
                    .frame(width: 8, height: 8)
                    .shadow(color: tint.opacity(0.9), radius: 10)
            }

            Text(title)
                .font(.wakeHeadline(24))
                .foregroundStyle(Color.wakeInk)

            Text(subtitle)
                .font(.wakeBody(size: 14, weight: .medium))
                .foregroundStyle(Color.wakeInkSoft)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
        .background {
            WakePixelShape(cut: 26)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 26)
                .stroke(Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: tint.opacity(0.12), radius: 16)
    }
}

struct WakeTabBar: View {
    let items: [WakeTabItem]
    @Binding var selection: AppState.MainTab

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items) { item in
                let isSelected = item.id == selection

                Button {
                    withAnimation(.snappy(duration: 0.2)) {
                        selection = item.id
                    }
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 19, weight: .semibold))
                        Text(item.title)
                            .font(.wakePixel(11))
                    }
                    .foregroundStyle(isSelected ? Color.wakeButter : Color.wakeInkSoft)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 56)
                    .background {
                        WakePixelShape(cut: 20)
                            .fill(isSelected ? Color.wakePanel : Color.clear)
                    }
                    .overlay {
                        WakePixelShape(cut: 20)
                            .stroke(isSelected ? Color.wakeBorder : Color.clear, lineWidth: 1)
                    }
                    .shadow(color: isSelected ? Color.wakeButter.opacity(0.18) : .clear, radius: 14)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background {
            WakePixelShape(cut: AppTheme.Corner.tabBar)
                .fill(Color.wakePaperDeep.opacity(0.96))
        }
        .overlay {
            WakePixelShape(cut: AppTheme.Corner.tabBar)
                .stroke(Color.wakeBorder, lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.4), radius: 20, y: 10)
    }
}

struct WakeTabItem: Identifiable {
    let id: AppState.MainTab
    let title: String
    let badge: String
    let symbol: String
}

extension Font {
    static func wakeHeadline(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func wakeBody(size: CGFloat = 16, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    static func wakePixel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func wakeButton() -> Font {
        .system(size: 20, weight: .heavy, design: .rounded)
    }

    static func wakeDisplay(_ size: CGFloat) -> Font {
        .system(size: size, weight: .black, design: .rounded).monospacedDigit()
    }
}

extension MissionKind {
    var tint: Color {
        switch self {
        case .typing:
            return .wakeButter
        case .rapidTap:
            return .wakeSky
        case .chaseButton:
            return .wakePlum
        }
    }

    var marker: String {
        switch self {
        case .typing:
            return "TXT"
        case .rapidTap:
            return "100"
        case .chaseButton:
            return "RUN"
        }
    }
}

extension GroupMemberStatus {
    var tintColor: Color {
        switch self {
        case .beforeWake:
            return .wakeFog
        case .alerting:
            return .wakeTomato
        case .awake:
            return .wakeButter
        case .failed:
            return .wakeFailure
        }
    }

    var boardCopy: String {
        switch self {
        case .beforeWake:
            return "기상 전"
        case .alerting:
            return "알림 진행 중"
        case .awake:
            return "기상 완료"
        case .failed:
            return "기상 실패"
        }
    }
}

extension AvatarSticker {
    var cardTint: Color {
        switch self {
        case .rabbit:
            return Color.wakeButter.opacity(0.16)
        case .chick:
            return Color.wakeTomato.opacity(0.18)
        case .cloud:
            return Color.wakeSky.opacity(0.18)
        case .moon:
            return Color.wakePlum.opacity(0.18)
        }
    }

    var accentTint: Color {
        switch self {
        case .rabbit:
            return .wakeButter
        case .chick:
            return .wakeTomato
        case .cloud:
            return .wakeSky
        case .moon:
            return .wakePlum
        }
    }

    var frameTint: Color {
        switch self {
        case .rabbit:
            return .wakeButter.opacity(0.8)
        case .chick:
            return .wakeTomato.opacity(0.72)
        case .cloud:
            return .wakeSky.opacity(0.78)
        case .moon:
            return .wakePlum.opacity(0.78)
        }
    }

    var spriteRows: [String] {
        switch self {
        case .rabbit:
            return [
                ".P....P.",
                "PP....PP",
                "PSP..PSP",
                "PPPPPPPP",
                ".PLLLLP.",
                "PLFLLFLP",
                ".PLLFFP.",
                "..PPPP.."
            ]
        case .chick:
            return [
                "..PPPP..",
                ".PPPPPP.",
                "PPPPPPPP",
                "PPLFFLPP",
                "PPLLLLPP",
                ".PPAAPP.",
                "..PPPP..",
                "...PP..."
            ]
        case .cloud:
            return [
                "..PPPP..",
                ".PPPPPP.",
                "PPPPPPPP",
                "PPLFFLPP",
                "PPLLLLPP",
                ".PPPPPP.",
                "..PPPP..",
                ".P....P."
            ]
        case .moon:
            return [
                "...PP...",
                "..PPPP..",
                ".PPPLLP.",
                ".PPLLL..",
                ".PPLFF..",
                ".PPLLL..",
                "..PPPP..",
                "...PP..."
            ]
        }
    }

    func spriteColor(for token: Character) -> Color {
        switch token {
        case "P":
            switch self {
            case .rabbit:
                return .white
            case .chick:
                return .wakeButter
            case .cloud:
                return .wakeSky
            case .moon:
                return .wakePlum
            }
        case "S":
            return .wakeTomato
        case "L":
            switch self {
            case .rabbit:
                return Color(red: 0.86, green: 0.88, blue: 0.78)
            case .chick:
                return Color(red: 0.96, green: 0.93, blue: 0.76)
            case .cloud:
                return .white
            case .moon:
                return .wakeButter
            }
        case "A":
            return .wakeTomato
        case "F":
            return .black.opacity(0.82)
        default:
            return .clear
        }
    }
}

enum WakeMascotKind {
    case sun
    case sleepMoon
    case cat
    case bird
    case wingBird

    var glowColor: Color {
        switch self {
        case .sun, .cat:
            return .wakeButter
        case .sleepMoon:
            return Color(red: 0.80, green: 0.73, blue: 0.98)
        case .bird, .wingBird:
            return .wakeSky
        }
    }

    var rows: [String] {
        switch self {
        case .sun:
            return [
                "....Y...Y....",
                "...YYYYYYY...",
                "..YYWWWWWYY..",
                ".YYWWKWWKWWY.",
                "YYYWWWWWLWWYY",
                ".YYWLLLLLWWY.",
                "..YYWWWWWYY..",
                "...YYYYYYY...",
                "....Y...Y...."
            ]
        case .sleepMoon:
            return [
                ".....PPPPP...",
                "...PPPPPPPP..",
                "..PPLLLLLLPP.",
                ".PPLLLKLLLLPP",
                ".PPLLLLLLLLPP",
                ".PPLLLLZLLLPP",
                "..PPLLLLLLPP.",
                "...PPPPPPPP..",
                ".....PPPPP.P."
            ]
        case .cat:
            return [
                "..W......W..",
                ".WWW....WWW.",
                ".WWWWWWWWWW.",
                "WWWWKWWKWWWW",
                "WWWMMMMMMWWW",
                ".WWWLMMLWWW.",
                "..WWWWWWWW..",
                "..WW.WW.WW..",
                ".YY..WW..YY."
            ]
        case .bird:
            return [
                "....BBBB....",
                "..BBBBBBBB..",
                ".BBBWWWWBBB.",
                "BBBWWKBKWWBB",
                "BBBWWWWWWBBB",
                ".BBBBBBBBBB.",
                "..BBBBBBBB..",
                "...BB..BBB.."
            ]
        case .wingBird:
            return [
                "BB........BB",
                "BBBB....BBBB",
                ".BBBBBBBBBB.",
                "..BBWWWWBB..",
                ".BBWWKBKWWBB",
                "BBBWWWWWWBBB",
                ".BBBBBBBBBB.",
                "...BBBBBB...",
                "....BB.B...."
            ]
        }
    }

    func color(for token: Character) -> Color {
        switch token {
        case "Y":
            return .wakeButter
        case "W":
            return .white
        case "P":
            return Color(red: 0.75, green: 0.68, blue: 0.97)
        case "L":
            switch self {
            case .sun:
                return Color(red: 1.0, green: 0.95, blue: 0.68)
            case .sleepMoon:
                return Color(red: 0.86, green: 0.80, blue: 1.0)
            case .cat:
                return Color(red: 0.95, green: 0.95, blue: 0.86)
            default:
                return .white
            }
        case "B":
            return .wakeSky
        case "K":
            return .black.opacity(0.92)
        case "M":
            return .wakePlum.opacity(0.82)
        case "Z":
            return .black.opacity(0.75)
        default:
            return .clear
        }
    }
}

struct WakeMascotSticker: View {
    let kind: WakeMascotKind
    var size: CGFloat = 72
    var flipHorizontally = false

    var body: some View {
        let rows = kind.rows
        let columns = rows.map(\.count).max() ?? 1
        let pixel = max(2, floor(size / CGFloat(max(rows.count, columns))))

        ZStack {
            WakeMatrixSprite(rows: rows, pixel: pixel) { token in
                kind.color(for: token)
            }
        }
        .padding(pixel)
        .shadow(color: kind.glowColor.opacity(0.22), radius: size * 0.12)
        .scaleEffect(x: flipHorizontally ? -1 : 1, y: 1)
        .drawingGroup()
    }
}

private struct WakeMatrixSprite: View {
    let rows: [String]
    let pixel: CGFloat
    let colorForToken: (Character) -> Color

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 0) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, token in
                        Rectangle()
                            .fill(colorForToken(token))
                            .frame(width: pixel, height: pixel)
                    }
                }
            }
        }
        .fixedSize()
    }
}

private struct WakePixelBoardStamp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WakeTape(text: "BOARD", fill: .wakeSky, ink: .black)

            VStack(spacing: 10) {
                boardRow(fill: .wakeButter, width: 56)
                boardRow(fill: .wakePlum, width: 42)
                boardRow(fill: .wakeSky, width: 68)
            }

            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { index in
                    Capsule()
                        .fill(index < 3 ? Color.wakeButter : Color.wakeBorder)
                        .frame(width: 16, height: 8)
                }
            }
        }
        .padding(18)
        .frame(width: 140, height: 140, alignment: .topLeading)
        .background {
            WakePixelShape(cut: 28)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 28)
                .stroke(Color.wakeSky.opacity(0.48), lineWidth: 1)
        }
        .shadow(color: Color.wakeSky.opacity(0.12), radius: 16)
    }

    private func boardRow(fill: Color, width: CGFloat) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(fill)
                .frame(width: 10, height: 10)

            Capsule()
                .fill(Color.wakeFog)
                .frame(width: width, height: 8)

            Spacer(minLength: 0)
        }
    }
}

private struct WakePixelMissionStamp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WakeTape(text: "MISSION", fill: .wakePlum, ink: .wakeInk)

            HStack(spacing: 8) {
                miniBadge(text: "TXT", fill: .wakeButter)
                miniBadge(text: "100", fill: .wakeSky)
                miniBadge(text: "RUN", fill: .wakePlum)
            }

            VStack(alignment: .leading, spacing: 10) {
                Capsule()
                    .fill(Color.wakeInk)
                    .frame(width: 84, height: 12)

                Capsule()
                    .fill(Color.wakeFog)
                    .frame(width: 102, height: 8)

                Capsule()
                    .fill(Color.wakeFog)
                    .frame(width: 62, height: 8)
            }
        }
        .padding(18)
        .frame(width: 140, height: 140, alignment: .topLeading)
        .background {
            WakePixelShape(cut: 28)
                .fill(Color.wakePanel)
        }
        .overlay {
            WakePixelShape(cut: 28)
                .stroke(Color.wakePlum.opacity(0.48), lineWidth: 1)
        }
        .shadow(color: Color.wakePlum.opacity(0.12), radius: 16)
    }

    private func miniBadge(text: String, fill: Color) -> some View {
        Text(text)
            .font(.wakePixel(9))
            .foregroundStyle(Color.black.opacity(0.9))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                WakePixelShape(cut: 14)
                    .fill(fill)
            }
    }
}

struct WakeBackGlyph: View {
    var body: some View {
        Image(systemName: "chevron.left")
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(Color.wakeInk)
    }
}

struct WakePixelShape: InsettableShape {
    var cut: CGFloat = 8
    var insetAmount: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let radius = min(max(cut, 12), min(rect.width, rect.height) / 2)
        return RoundedRectangle(cornerRadius: radius, style: .continuous).path(in: rect)
    }

    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}
