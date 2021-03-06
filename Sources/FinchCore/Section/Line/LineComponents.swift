/// :nodoc:
public struct LineComponents {
    enum Kind: Int {
        case sha = 1
        case message
        case pullRequestNumber
        case contributorEmail
    }

    public let contributorEmail: String
    public let message: String
    public let pullRequestNumber: Int?
    public let sha: String
    public let tags: [String]

    /// :nodoc:
    public init(rawLine: String, configuration: Configuration, normalizeTags: Bool) {
        let componentString: (Kind) -> String = { kind in
            rawLine.component(kind: kind, configuration: configuration)
        }

        self.contributorEmail = componentString(.contributorEmail)
        self.message = (
            Regex.Pattern.filteredMessagePattern(from: configuration).firstMatch(in: rawLine) ??
                componentString(.message)
        ).trimmingCharacters(in: .whitespacesAndNewlines)
        self.pullRequestNumber = Int(componentString(.pullRequestNumber))
        self.sha = componentString(.sha)
        self.tags = Regex.Pattern.tagPattern(from: configuration)
            .matches(in: rawLine)
            .compactMap { $0.firstMatch(in: rawLine) }
            .map { normalizeTags ? $0.lowercased() : $0 }
    }
}

/// :nodoc:
extension LineComponents.Kind {
    var regEx: String {
        switch self {
        case .sha:
            return "(?:\(border))(.*?)(?:\(border))"
        case .message:
            return "\(border)(.*?)\\(?:#(.*?)\\)\(border)"
        case .pullRequestNumber:
            return "\\d+?\\\(border)"
        case .contributorEmail:
            return "\(border)(.*?)\(border)"
        }
    }

    var border: String {
        switch self {
        case .sha:
            return "&&&"
        case .message:
            return "@@@"
        case .pullRequestNumber:
            return ")@@@"
        case .contributorEmail:
            return "###"
        }
    }
}

extension String {
    fileprivate func component(kind: LineComponents.Kind, configuration: Configuration) -> String {
        if let match = range(of: kind.regEx, options: [.regularExpression]) {
            return String(self[match]).replacingOccurrences(of: kind.border, with: "")
        }

        let extractionPattern = Regex.Replacement(matching: .rawPattern, replacement: "$\(kind.rawValue)")

        return extractionPattern.findReplace(in: self)
    }
}
