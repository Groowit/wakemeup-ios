import Foundation

enum MissionKind: String, CaseIterable, Hashable {
    case typing
    case rapidTap
    case chaseButton
}

struct MissionTemplate: Identifiable, Hashable {
    let id: UUID
    var kind: MissionKind
    var title: String
    var detail: String
    var badgeText: String
    var sampleText: String
}
