//
//  Regex.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

//public static func findReplace(in body: String, using pattern: Regex.Replacement) -> String {
//    return findReplace(pattern: pattern.matching, in: body, with: pattern.replacement)
//}
//
//public static func findReplace(pattern: String, in body: String, with replacement: String) -> String {
//    guard !pattern.isEmpty || !body.isEmpty else {
//        return body
//    }
//    guard let expression = try? NSRegularExpression(
//        pattern: pattern,
//        options: [.anchorsMatchLines, .useUnixLineSeparators]
//        ) else {
//            return body
//    }
//
//    return expression.stringByReplacingMatches(
//        in: body,
//        options: [],
//        range: .init(location: 0, length: body.count),
//        withTemplate: replacement
//    )
//}
//
//public static func matches(pattern: Regex.Pattern, body: String) -> [NSTextCheckingResult] {
//    guard let expression = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else {
//        return []
//    }
//
//    let range: NSRange = .init(location: 0, length: body.count)
//    let options: NSRegularExpression.MatchingOptions = [.withTransparentBounds]
//
//    return expression.matches(in: body, options: options, range: range)
//}
//
//public static func firstMatch(pattern: Regex.Pattern, body: String) -> String? {
//    return Utilities.matches(pattern: pattern, body: body)
//        .first?
//        .firstMatch(in: body)
//}
//
//extension NSTextCheckingResult {
//    func firstMatch(in body: String) -> String? {
//        guard numberOfRanges > 0 else {
//            return nil
//        }
//
//        return String(range: range(at: 1), in: body)
//    }
//}
