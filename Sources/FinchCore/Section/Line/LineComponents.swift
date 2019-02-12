//
//  LineComponents.swift
//  Finch
//
//  Created by Dan Loman on 8/15/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

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

    public init(rawLine: String, configuration: Configuration) {
        let componentString: (Kind) -> String = { kind in
            rawLine.component(kind: kind, configuration: configuration)
        }

        self.contributorEmail = componentString(.contributorEmail)
        self.message = (Regex.Pattern.filteredMessagePattern(from: configuration).firstMatch(in: rawLine) ??
            componentString(.message)).trimmingCharacters(in: .whitespacesAndNewlines)
        self.pullRequestNumber = Int(componentString(.pullRequestNumber))
        self.sha = componentString(.sha)
        self.tags = Regex.Pattern.tagPattern(from: configuration)
            .matches(in: rawLine)
            .compactMap { $0.firstMatch(in: rawLine) }
    }
}

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

private extension String {
    func component(kind: LineComponents.Kind, configuration: Configuration) -> String {
        if let match = range(of: kind.regEx, options: [.regularExpression]) {
            return String(self[match]).replacingOccurrences(of: kind.border, with: "")
        }

        let extractionPattern = Regex.Replacement(matching: .rawPattern, replacement: "$\(kind.rawValue)")

        return extractionPattern.findReplace(in: self)
    }
}
