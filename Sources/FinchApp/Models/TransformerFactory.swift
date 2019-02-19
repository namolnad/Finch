//
//  TransformerFactory.swift
//  FinchApp.swift
//
//  Created by Dan Loman on 7/5/18.F
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchCore
import FinchUtilities

/// :nodoc:
struct TransformerFactory {
    private let configuration: Configuration

    var initialTransformers: [Transformer] {
        return [
            exclusionTransformers,
            formattingTransformers
        ].flatMap { $0 }
    }

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    private var exclusionTransformers: [Transformer] {
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

    private var formattingTransformers: [Transformer] {
        let patterns: [Regex.Replacement] = [
            .init(matching: "^>", replacement: " -")
        ]

        return patterns.map(Transformer.init)
    }
}
