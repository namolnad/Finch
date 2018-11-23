//
//  Outputs.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Utilities {
    struct OutputGenerator {
        private let version: String?
        private let releaseManager: Contributor?
        private let sections: [Section]
        private let footer: String?
        private let contributorHandlePrefix: String
    }
}

extension Utilities.OutputGenerator {
        let patternCreator = FindReplacePatternCreator(configuration: configuration)
    init(configuration: Configuration, rawDiff: String, version: String?, releaseManager: Contributor?) {

        let lines = type(of: self).primaryOutput(for: patternCreator.patterns, with: rawDiff)
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
            .compactMap { Line(configuration: configuration, value: $0) }

        var sections: [String: Section] = [:]

        let tagToSectionInfo: [String: SectionInfo] = configuration.sectionInfos.reduce(into: [:]) { tagSectionInfoMap, sectionInfo in
            sectionInfo.tags.forEach { tag in
                tagSectionInfoMap[tag] = sectionInfo
            }
        }

        lines.forEach {
            $0.placeInOwningSection(tagToSectionInfo: tagToSectionInfo, titleToSection: &sections)
        }

        self.version = version
        self.releaseManager = releaseManager
        self.sections = configuration.sectionInfos.compactMap { sections[$0.title] }
        self.footer = configuration.footer
        self.contributorHandlePrefix = configuration.contributorHandlePrefix
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
            .reduce(sortedInput, Utilities.findReplace)
    }

    private func header(version: String) -> String {
        return """

        # \(version)
        
        """
    }

    private func formatted(releaseManager: Contributor) -> String {
        return """

        ### Release Manager

         - \(contributorHandlePrefix)\(releaseManager.handle)

        """
    }
}
