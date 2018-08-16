//
//  Regex.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

func findReplace(in body: String, with pattern: FindReplacePattern) -> String {
    return findReplace(pattern: pattern.text, in: body, with: pattern.replacement)
}

func findReplace(pattern: String, in body: String, with replacement: String) -> String {
    guard !pattern.isEmpty || !body.isEmpty else {
        return body
    }
    guard let expression = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .useUnixLineSeparators]) else {
        return body
    }

    return expression.stringByReplacingMatches(in: body, options: [], range: .init(location: 0, length: body.count), withTemplate: replacement)
}

func matches(pattern: String, body: String) -> [NSTextCheckingResult] {
    guard let expression = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else {
        return []
    }

    let range: NSRange = .init(location: 0, length: body.count)
    let options: NSRegularExpression.MatchingOptions = [.withTransparentBounds]

    return expression.matches(in: body, options: options, range: range)
}
