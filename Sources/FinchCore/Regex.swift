import FinchUtilities
import Foundation

/// :nodoc:
public enum Regex {
    public typealias Pattern = String

    /// :nodoc:
    public struct Replacement {
        public let matching: Pattern
        public let replacement: Pattern

        public init(matching: Pattern, replacement: Pattern) {
            self.matching = matching
            self.replacement = replacement
        }
    }
}

/// :nodoc:
extension Regex.Replacement {
    public func findReplace(in body: String) -> String {
        findReplace(pattern: matching, in: body, with: replacement)
    }

    private func findReplace(pattern: String, in body: String, with replacement: String) -> String {
        guard [pattern, body].contains(where: { !$0.isEmpty }) else {
            return body
        }
        guard
            let expression = try? NSRegularExpression(
                pattern: pattern,
                options: [.anchorsMatchLines, .useUnixLineSeparators]
            )
        else { return body }

        return expression.stringByReplacingMatches(
            in: body,
            options: [],
            range: .init(location: 0, length: body.utf16.count),
            withTemplate: replacement
        )
    }
}

/// :nodoc:
extension Regex.Pattern {
    func matches(in body: String) -> [NSTextCheckingResult] {
        guard let expression = try? NSRegularExpression(pattern: self, options: [.anchorsMatchLines]) else {
            return []
        }

        let range: NSRange = .init(location: 0, length: body.utf16.count)
        let options: NSRegularExpression.MatchingOptions = [.withTransparentBounds]

        return expression.matches(in: body, options: options, range: range)
    }

    func firstMatch(in body: String) -> String? {
        matches(in: body)
            .first?
            .firstMatch(in: body)
    }
}

/// :nodoc:
extension NSTextCheckingResult {
    func firstMatch(in body: String) -> String? {
        guard numberOfRanges > 0 else {
            return nil
        }

        return String(range: range(at: 1), in: body)
    }
}

/// :nodoc:
extension Regex.Pattern {
    static let rawPattern: Regex.Pattern = "&&&(.*?)&&&(?:.*?)@@@(.*?)\\(#(.*?)\\)@@@###(.*?)###"

    /// Captures a single commit's log output, whose message may span multiple lines.
    static let commitPattern: Regex.Pattern = "^(.*?)&&&(.*?)&&&(.*?)@@@([\\s\\S]*)@@@###(.*?)###"

    /// Matches the trailing pull request reference of a commit message. e.g. ` (#1234)`
    static let pullRequestSuffixPattern: Regex.Pattern = "\\s*\\(#\\d+\\)$"

    static let shaPattern: Regex.Pattern = "&&&(.*?)&&&"

    /// Captures the message a commit's log output carries.
    static let messagePattern: Regex.Pattern = "@@@([\\s\\S]*)@@@"

    /// Captures the breaking change description carried alongside an entry.
    static let breakingPattern: Regex.Pattern = "%%%([\\s\\S]*)%%%"

    /**
     * Captures a Conventional Commits message: the type, any scopes, the `!`
     * marking a breaking change, and the description. The type is restricted
     * to lower case so that ordinary prose containing a colon — `Note: ...`,
     * `Fixes: #12` — is not mistaken for one.
     */
    static let conventionalPattern: Regex.Pattern = "^([a-z][a-z-]*)(?:\\(([^)]*)\\))?(!)?:[ ]*([\\s\\S]*)$"

    /// Matches only a conventional type opening the line, which starts an entry.
    static let conventionalPrefixPattern: Regex.Pattern = "^[a-z][a-z-]*(?:\\([^)]*\\))?!?:"

    /// Matches the footer form of a breaking change, per the specification.
    static let breakingFooterPattern: Regex.Pattern = "^BREAKING[ -]CHANGE:[ ]*"

    static func tagPattern(for delimiters: DelimiterPair) -> Regex.Pattern {
        "\(delimiters.left.escaped)(.*?)\(delimiters.right.escaped)"
    }

    /// Matches only a tag opening the line, marking the start of a changelog entry.
    static func tagPrefixPattern(for delimiters: DelimiterPair) -> Regex.Pattern {
        "^\(tagPattern(for: delimiters))"
    }

    /// Matches punctuation left behind once opening tags are removed.
    static let leadingSeparatorPattern: Regex.Pattern = "^[:\\s]+"

    /// Matches the run of tags opening a message, which the description drops.
    static func leadingTagsPattern(for delimiters: DelimiterPair) -> Regex.Pattern {
        "^(?:\(delimiters.left.escaped)(?:.*?)\(delimiters.right.escaped))+"
    }
}
