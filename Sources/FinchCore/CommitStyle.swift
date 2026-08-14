import Foundation

/**
 * The convention a project's commit messages follow, which decides how a
 * message is split into the tags routing it to a section and the description
 * which is printed.
 */
public enum CommitStyle: String, CaseIterable, Codable, Sendable {
    /**
     * [Conventional Commits](https://www.conventionalcommits.org):
     * `type(scope)!: description`.
     *
     * The type and any scopes become tags, and a `!` — or a line opening with
     * `BREAKING CHANGE:` — contributes a `breaking` tag.
     * > This is the default
     */
    case conventional

    /**
     * Finch's original convention: one or more delimited tags opening the
     * message, as in `[tag][other] description`, using the delimiters from
     * the format configuration.
     */
    case delimited
}

/// The tags and description parsed out of a single commit message.
struct CommitComponents {
    let tags: [String]
    let description: String
}

/**
 * Splits commit messages according to the project's `CommitStyle`.
 *
 * Every read of a commit message goes through here: which tags it carries,
 * what is left to print, and whether a line opens an entry of its own.
 */
struct CommitParser {
    /**
     * The types which may open an entry from within a commit body.
     *
     * A subject is known to be a commit message, so any type is read from it.
     * A body line is not: prose wraps, and a paragraph reading `…was right for
     * the build and wrong for the` / `tests: the file is regenerated…` would
     * otherwise contribute a `tests` entry. Holding body lines to the types the
     * specification names keeps wrapped prose out of the changelog.
     */
    private static let conventionalTypes: Set<String> = [
        "build", "chore", "ci", "docs", "feat", "fix",
        "perf", "refactor", "revert", "style", "test"
    ]

    private let style: CommitStyle
    private let delimiters: DelimiterPair

    init(configuration: Configuration) {
        self.style = configuration.formatConfig.commitStyle ?? .conventional
        self.delimiters = configuration.formatConfig.delimiterConfig.input
    }

    /// Returns the tags and printable description of a commit message.
    func components(of message: String) -> CommitComponents {
        let message = message.trimmingCharacters(in: .whitespacesAndNewlines)

        switch style {
        case .conventional:
            return conventionalComponents(of: message)
        case .delimited:
            return delimitedComponents(of: message)
        }
    }

    /**
     * Whether a line opens a changelog entry of its own, which is what allows
     * a single commit to be represented in more than one section.
     */
    func opensEntry(_ line: String) -> Bool {
        switch style {
        case .conventional:
            guard
                let match = Regex.Pattern.conventionalPattern.matches(in: line).first,
                let type = match.firstMatch(in: line)
            else { return false }

            return Self.conventionalTypes.contains(type)
        case .delimited:
            return line.range(
                of: Regex.Pattern.tagPrefixPattern(for: delimiters),
                options: .regularExpression
            ) != nil
        }
    }

    /**
     * The description a `BREAKING CHANGE:` footer carries, if the line is one.
     *
     * A footer describes the commit rather than standing on its own, so it is
     * read as the commit's breaking change rather than as an entry — and it is
     * recognized whichever style the project writes its subjects in.
     */
    func breakingDescription(inFooter line: String) -> String? {
        guard let range = line.range(of: Regex.Pattern.breakingFooterPattern, options: .regularExpression) else {
            return nil
        }

        return String(line[range.upperBound...]).trimmingCharacters(in: .whitespaces)
    }

    private func conventionalComponents(of message: String) -> CommitComponents {
        guard
            let match = Regex.Pattern.conventionalPattern.matches(in: message).first,
            match.numberOfRanges == 5
        else {
            guard message.range(of: Regex.Pattern.breakingFooterPattern, options: .regularExpression) != nil else {
                return .init(tags: [], description: stripped(message))
            }

            let description = message
                .replacingOccurrences(of: Regex.Pattern.breakingFooterPattern, with: "", options: .regularExpression)

            return .init(tags: [Strings.breakingTag], description: stripped(description))
        }

        func component(_ index: Int) -> String? {
            guard match.range(at: index).location != NSNotFound else {
                return nil
            }

            return String(range: match.range(at: index), in: message)
        }

        let scopes = (component(2) ?? "")
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let isBreaking = component(3) != nil

        // Breaking leads, since sections are matched in tag order and a
        // breaking change belongs under that heading ahead of its type
        return .init(
            tags: (isBreaking ? [Strings.breakingTag] : []) + [component(1)].compactMap(\.self) + scopes,
            description: stripped(component(4) ?? "")
        )
    }

    private func delimitedComponents(of message: String) -> CommitComponents {
        let tags = Regex.Pattern
            .tagPattern(for: delimiters)
            .matches(in: message)
            .compactMap { $0.firstMatch(in: message) }

        let description = message
            .replacingOccurrences(
                of: Regex.Pattern.leadingTagsPattern(for: delimiters),
                with: "",
                options: .regularExpression
            )
            // `[tag]: description` is a common shape — dependabot writes it —
            // and the colon should not survive the tag being taken off
            .replacingOccurrences(
                of: Regex.Pattern.leadingSeparatorPattern,
                with: "",
                options: .regularExpression
            )

        return .init(tags: tags, description: stripped(description))
    }

    /// Removes the trailing pull request reference, which is rendered separately.
    private func stripped(_ description: String) -> String {
        description
            .replacingOccurrences(
                of: Regex.Pattern.pullRequestSuffixPattern,
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension CommitParser {
    enum Strings {
        static let breakingTag: String = "breaking"
    }
}
