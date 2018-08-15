//
//  Outputs.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Output {

    let version: String?

    let releaseManager: User?

    let sections: [Section]

    let footer: String?

    var finalOutput: String {
        var output = ""

        if let value = version {
            output.append(header(version: value))
        }

        if let value = releaseManager {
            output.append(formatted(releaseManager: value))
        }

        sections.forEach {
            output.append(body(lines: $0.lines, title: $0.info.title))
        }

        if let value = footer {
            output.append(value)
        }

        return output
    }

    private func body(lines: [String], title: String) -> String {
        let output = """

        ### \(title)

        """

        return lines.reduce(output) {
            return $0 + $1 + "\n"
        }
    }

    // Primary parsing
    static func primaryOutput(for patterns: [[FindReplacePattern]], with input: String) -> String {
        let sortedInput = input
            .components(separatedBy: "\n")
            .sorted(by: "@@@(.*)@@@")
            .joined(separator: "\n")

        return patterns
            .flatMap { $0 }
            .reduce(sortedInput, findReplace)
    }

    private func header(version: String) -> String {
        return """

        # \(version)
        
        """
    }

    private func formatted(releaseManager: User) -> String {
        return """

        ### Release Manager

         - \(releaseManager.formattedQuipName)

        """
    }
}
