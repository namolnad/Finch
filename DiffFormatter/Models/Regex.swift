//
//  Regex.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

enum Regex {
    typealias Pattern = String

    struct Replacement {
        let matching: Pattern
        let replacement: Pattern
    }
}

extension Regex.Pattern {
    static let rawPattern: Regex.Pattern = "&&&(.*?)&&&(?:.*?)@@@(.*?)\\(#(.*?)\\)@@@###(.*?)###"

    static func contributorPattern(from contributor: Contributor) -> Regex.Pattern {
        return "###\(contributor.email.escaped)###"
    }

    static func filteredMessagePattern(from configuration: Configuration) -> Regex.Pattern {
        let leftDelim = configuration.delimiterConfig.input.left.escaped
        let rightDelim = configuration.delimiterConfig.input.right.escaped

        return "@@@(?:\(leftDelim)(?:.*?)\(rightDelim))*(.*?)(?: \\(#\\d+\\))?@@@"
    }

    static func tagPattern(from configuration: Configuration) -> Regex.Pattern {
        let leftDelim = configuration.delimiterConfig.input.left.escaped
        let rightDelim = configuration.delimiterConfig.input.right.escaped

        return "\(leftDelim)(.*?)\(rightDelim)"
    }
}

