import Foundation

struct GroupDraft: Equatable {
    enum Source: String, Equatable {
        case create
        case join
    }

    var source: Source
    var name: String = ""
    var memberCount: Int = 3
    var inviteCode: String

    var resolvedName: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
