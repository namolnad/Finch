//
//  Transformer.swift
//  FinchApp.swift
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchCore

/// :nodoc:
struct Transformer {
    let pattern: Regex.Replacement

    func transform(text: String) -> String {
        pattern.findReplace(in: text)
    }
}

/// :nodoc:
extension Array where Element == Transformer {
    static func `default`(for configuration: Configuration) -> [Transformer] {
        [
            exclusionTransformers(for: configuration),
            formattingTransformers
        ].flatMap { $0 }
    }

    private static func exclusionTransformers(for configuration: Configuration) -> [Transformer] {
        let inputDelimiters = configuration.formatConfig.delimiterConfig.input

        let patterns: [Regex.Replacement] = [
            .init(
                matching: "^(.*)(@@@(.*)@@@)(.*)(\n(.*)\\2(.*))+$",
                replacement: ""
            ),
            .init(
                matching: "^<(.*)$",
                replacement: ""
            ),
            .init(
                matching: "^(.*)@@@\(inputDelimiters.left.escaped)version\(inputDelimiters.right.escaped)(.*)$",
                replacement: ""
            )
        ]

        return patterns.map(Transformer.init)
    }

    private static var formattingTransformers: [Transformer] {
        let patterns: [Regex.Replacement] = [
            .init(matching: "^>", replacement: " -")
        ]

        return patterns.map(Transformer.init)
    }
}
