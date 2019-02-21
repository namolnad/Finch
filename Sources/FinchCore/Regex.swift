//
//  Regex.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

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
        return findReplace(pattern: matching, in: body, with: replacement)
    }

    private func findReplace(pattern: String, in body: String, with replacement: String) -> String {
        guard [pattern, body].contains(where: { !$0.isEmpty }) else {
            return body
        }
        guard let expression = try? NSRegularExpression(
            pattern: pattern,
            options: [.anchorsMatchLines, .useUnixLineSeparators]
            ) else {
                return body
        }

        return expression.stringByReplacingMatches(
            in: body,
            options: [],
            range: .init(location: 0, length: body.count),
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

        let range: NSRange = .init(location: 0, length: body.count)
        let options: NSRegularExpression.MatchingOptions = [.withTransparentBounds]

        return expression.matches(in: body, options: options, range: range)
    }

    func firstMatch(in body: String) -> String? {
        return matches(in: body)
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

    static func filteredMessagePattern(from configuration: Configuration) -> Regex.Pattern {
        let input = configuration.formatConfig.delimiterConfig.input

        return "@@@(?:\(input.left.escaped)(?:.*?)\(input.right.escaped))*(.*?)(?: \\(#\\d+\\))?@@@"
    }

    static func tagPattern(from configuration: Configuration) -> Regex.Pattern {
        let input = configuration.formatConfig.delimiterConfig.input

        return "\(input.left.escaped)(.*?)\(input.right.escaped)"
    }
}
