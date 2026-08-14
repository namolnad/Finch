import Foundation

/// :nodoc:
public enum RawLog {}

/// :nodoc:
extension RawLog {
    /// The components captured from a single commit's log output.
    private enum Component: Int {
        case prefix = 1
        case sha
        case separator
        case message
        case contributorEmail
    }

    /**
     * Splits a raw git log into the individual lines from which changelog
     * entries are derived — one line per entry.
     *
     * A commit contributes an entry for each tagged line in its message —
     * every entry carrying that commit's sha, pull request number and author
     * email — which allows a single commit to be represented in more than one
     * section. An untagged line extends the entry above it, unless the two are
     * separated by a blank line, in which case it is dropped. Any input which
     * does not describe a commit is passed through untouched.
     */
    public static func entryLines(from rawLog: String, configuration: Configuration) -> [String] {
        rawLog
            .components(separatedBy: "\n")
            .reduce(into: [[String]]()) { commits, line in
                if commits.isEmpty || line.isCommitStart {
                    commits.append([line])
                } else {
                    commits[commits.index(before: commits.endIndex)].append(line)
                }
            }
            .flatMap { entryLines(fromCommit: $0, configuration: configuration) }
    }

    /// Returns a line per changelog entry found in a single commit's log output.
    private static func entryLines(fromCommit commitLines: [String], configuration: Configuration) -> [String] {
        let commit = commitLines.joined(separator: "\n")

        guard let match = Regex.Pattern.commitPattern.matches(in: commit).first else {
            return commitLines
        }

        func component(_ component: Component) -> String {
            String(range: match.range(at: component.rawValue), in: commit)
        }

        let prefix = component(.prefix)
        let sha = component(.sha)
        let separator = component(.separator)
        let email = component(.contributorEmail)

        return entries(in: component(.message), configuration: configuration).map { entry in
            "\(prefix)&&&\(sha)&&&\(separator)@@@\(entry)@@@###\(email)###"
        }
    }

    /// Returns the message for each changelog entry within a commit message.
    private static func entries(in message: String, configuration: Configuration) -> [String] {
        let tagPrefix: Regex.Pattern = .tagPrefixPattern(from: configuration)

        var entries: [String] = []
        var isExtendable = false

        for line in message.components(separatedBy: "\n") {
            let value = line.trimmingCharacters(in: .whitespaces)

            // A blank line ends the entry above it
            guard !value.isEmpty else {
                isExtendable = false
                continue
            }

            if entries.isEmpty || value.range(of: tagPrefix, options: .regularExpression) != nil {
                entries.append(value)
                isExtendable = true
            } else if isExtendable {
                entries[entries.index(before: entries.endIndex)] += " " + value
            }
        }

        return propagatingPullRequest(across: entries)
    }

    /**
     * Applies the commit's pull request reference to each entry lacking one
     * of its own, ensuring every entry links back to the same pull request.
     */
    private static func propagatingPullRequest(across entries: [String]) -> [String] {
        let pattern: Regex.Pattern = .pullRequestSuffixPattern

        guard
            let subject = entries.first,
            let range = subject.range(of: pattern, options: .regularExpression)
        else { return entries }

        let reference = String(subject[range])

        return entries.map { entry in
            entry.range(of: pattern, options: .regularExpression) == nil ? entry + reference : entry
        }
    }
}

extension String {
    fileprivate var isCommitStart: Bool {
        range(of: Regex.Pattern.shaPattern, options: .regularExpression) != nil
    }
}
