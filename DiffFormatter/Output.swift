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

    let features: [String]

    let bugFixes: [String]

    let platformImprovements: [String]

    var timeline: String {
        return """

        ### Timeline
         - Begin development:
         - Feature cut-off / Start of bake / dogfooding:
         - Submission:
         - Release (expected):
         - Release (actual):
        """
    }

    var finalOutput: String {
        var output = ""

        if let value = version {
            output.append(header(version: value))
        }

        if let value = releaseManager {
            output.append(formatted(releaseManager: value))
        }

        if !features.isEmpty {
            output.append(body(lines: features, title: "Features"))
        }

        if !bugFixes.isEmpty {
            output.append(body(lines: bugFixes, title: "Bug Fixes"))
        }

        if !platformImprovements.isEmpty {
            output.append(body(lines: platformImprovements, title: "Platform Improvements"))
        }

        output.append(timeline)

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
    static func primary(input: String) -> String {
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

         - \(releaseManager.quipName)

        """
    }
}
