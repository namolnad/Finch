//
//  FindReplacePatterns.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

typealias FindReplacePattern = (text: String, replacement: String)

struct FindReplacePatternCreator {
    private let configuration: Configuration

    var patterns: [[FindReplacePattern]] {
        return [
            exclusionPatterns,
            authorPatterns,
            formattingPatterns,
            linkPatterns,
        ]
    }

    init(configuration: Configuration) {
        self.configuration = configuration
    }

    private let exclusionPatterns: [FindReplacePattern] = [
        ("^(.*)(@@@(.*)@@@)(.*)(\n(.*)\\2(.*))+$", ""),
        ("^<(.*)$", ""),
        ("^(.*)@@@\\[version\\](.*)$", ""),
        ]

    private let formattingPatterns: [FindReplacePattern] = [
        ("\\[", "|"),
        ("\\]", "|"),
        ("^>", " -"),
        ]

    private let linkPatterns: [FindReplacePattern] = [
        ("&&&(.*)&&&(.*)@@@(.*)\\(#(.*)\\)@@@", "$3— [PR #$4](https://github.com/instacart/instacart-ios/pull/$4) —"),
        ("&&&(.*)&&&(.*)@@@(.*)@@@", "$3 — [Commit](https://github.com/instacart/instacart-ios/commit/$1) —")
    ]

    private var authorPatterns: [FindReplacePattern] {
        return configuration.users.compactMap { FindReplacePattern(text: "###\($0.email)###", replacement: " \($0.formattedQuipName)") }
    }
}
