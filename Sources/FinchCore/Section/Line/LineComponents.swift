/// :nodoc:
public struct LineComponents {
    enum Kind: Int {
        case sha = 1
        case message
        case pullRequestNumber
        case contributorEmail
    }

    /// The description carried by the commit's `BREAKING CHANGE:` footer, if it has one.
    public let breakingChange: String?
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

        // Parsed from the message alone: the surrounding line carries a sha and
        // an author address, and an address such as `dependabot[bot]@…` would
        // otherwise read as a tag
        let message = Regex.Pattern.messagePattern.firstMatch(in: rawLine) ?? componentString(.message)
        let components = CommitParser(configuration: configuration).components(of: message)
        let breakingChange = Regex.Pattern.breakingPattern.firstMatch(in: rawLine)

        // A footer marks the commit breaking just as `!` does, so it earns the
        // same tag, and leads for the same reason
        let tags = breakingChange != nil && !components.tags.contains(CommitParser.Strings.breakingTag)
            ? [CommitParser.Strings.breakingTag] + components.tags
            : components.tags

        self.breakingChange = breakingChange
        self.contributorEmail = componentString(.contributorEmail)
        self.message = components.description
        self.pullRequestNumber = Int(componentString(.pullRequestNumber))
        self.sha = componentString(.sha)
        self.tags = tags.map { normalizeTags ? $0.lowercased() : $0 }
    }
}

/// :nodoc:
extension LineComponents.Kind {
    var regEx: String {
        switch self {
        case .sha:
            "(?:\(border))(.*?)(?:\(border))"
        case .message:
            "\(border)(.*?)\\(?:#(.*?)\\)\(border)"
        case .pullRequestNumber:
            "\\d+?\\\(border)"
        case .contributorEmail:
            "\(border)(.*?)\(border)"
        }
    }

    var border: String {
        switch self {
        case .sha:
            "&&&"
        case .message:
            "@@@"
        case .pullRequestNumber:
            ")@@@"
        case .contributorEmail:
            "###"
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
