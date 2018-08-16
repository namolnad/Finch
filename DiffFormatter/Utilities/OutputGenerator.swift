//
//  Outputs.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct OutputGenerator {
    private let version: String?
    private let releaseManager: User?
    private let sections: [Section]
    private let footer: String?
}

extension OutputGenerator {
    init(configuration: Configuration, rawDiff: String, version: String?, releaseManager: User?) {
        let patternCreator = FindReplacePatternCreator(configuration: configuration)

        let lines = type(of: self).primaryOutput(for: patternCreator.patterns, with: rawDiff)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .compactMap(Line.init)

        var sections: [String: Section] = [:]

        let reversedSectionInfos = configuration.sectionInfos.reversed()

        lines.forEach { line in
            if let sectionInfo = reversedSectionInfos.first(where: line.belongsTo) {
                let defaultSection = Section(info: sectionInfo, lines: [])
                sections[sectionInfo.title, default: defaultSection].lines.append(line.value)
            }
        }

        self.version = version
        self.releaseManager = releaseManager
        self.sections = configuration.sectionInfos.compactMap { sections[$0.title] }
        self.footer = configuration.footer
    }

    func generatedOutput() -> String {
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

        return lines.reduce(output) { $0 + $1 + "\n" }
    }

    // Primary parsing
    private static func primaryOutput(for patterns: [[FindReplacePattern]], with input: String) -> String {
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

         - \(releaseManager.formattedQuipHandle)

        """
    }
}
