//
//  Line_Components.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/15/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Section.Line {
    struct Components {
        enum Kind: Int {
            case sha = 1
            case message
            case pullRequestNumber
            case contributorEmail
        }

        let contributorEmail: String
        let message: String
        let pullRequestNumber: Int?
        let sha: String
        let tags: [String]

        init(rawLine: String, configuration: Configuration) {
            let componentString: (Kind) -> String = { kind in
                return rawLine.component(kind: kind, configuration: configuration)
            }

            self.contributorEmail = componentString(.contributorEmail)
            self.message = (Utilities.firstMatch(pattern: .filteredMessagePattern(from: configuration), body: rawLine) ?? componentString(.message)).trimmingCharacters(in: .whitespacesAndNewlines)
            self.pullRequestNumber = Int(componentString(.pullRequestNumber))
            self.sha = componentString(.sha)
            self.tags = Utilities.matches(pattern: .tagPattern(from: configuration), body: rawLine).compactMap { $0.firstMatch(in: rawLine) }
        }
    }
}

extension Section.Line.Components.Kind {
    var regEx: String {
        switch self {
        case .sha:
            return "(?:&&&)(.*?)(?:&&&)"
        case .message:
            return "@@@(.*?)\\(?:#(.*?)\\)@@@"
        case .pullRequestNumber:
            return "\\d+?\\)@@@"
        case .contributorEmail:
            return "###(.*?)###"
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

private extension String {
    func component(kind: Section.Line.Components.Kind, configuration: Configuration) -> String {
        if let match = range(of: kind.regEx, options: [.regularExpression]) {
            return String(self[match]).replacingOccurrences(of: kind.border, with: "")
        }

        let extractionPattern = Regex.Replacement(matching: .rawPattern, replacement: "$\(kind.rawValue)")

        return Utilities.findReplace(in: self, using: extractionPattern)
    }
}
