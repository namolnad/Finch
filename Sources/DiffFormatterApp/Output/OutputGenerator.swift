//
//  OutputGenerator.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterCore

struct OutputGenerator {
    private let version: String?
    private let releaseManager: Contributor?
    private let sections: [Section]
    private let footer: String?
    private let header: String?
    private let contributorHandlePrefix: String
}

extension OutputGenerator {
    init(configuration: Configuration, rawDiff: String, version: String?, releaseManager: Contributor?) {
        let transformerFactory = TransformerFactory(configuration: configuration)

        let linesComponents = type(of: self)
            .filteredLines(input: rawDiff, using: transformerFactory.initialTransformers)
            .compactMap { LineComponents(rawLine: $0, configuration: configuration) }

        var sections: [Section] = configuration
            .sectionInfos
            .map { Section(configuration: configuration, info: $0, linesComponents: []) }

        let tagToIndex: [String: Int] = sections
            .enumerated()
            .reduce([:]) { partial, next in
                var map = partial
                next.element.info.tags.forEach { tag in
                    map.updateValue(next.offset, forKey: tag)
                }
                return map
            }

        for components in linesComponents {
            let tag = components.tags.first(where: tagToIndex.keys.contains) ?? "*"
            guard let index = tagToIndex[tag] else {
                continue
            }
            let section = sections[index]

            sections[index] = section.inserting(lineComponents: components)
        }

        self.version = version
        self.releaseManager = releaseManager
        self.sections = sections.filter { !$0.info.excluded }
        self.footer = configuration.footer
        self.header = configuration.header
        self.contributorHandlePrefix = configuration.contributorHandlePrefix
    }

    func generateOutput() -> String {
        var output = ""

        if let value = header {
            output.append(value)
        }

        if let value = version {
            output.append(version(value))
        }

        if let value = releaseManager {
            output.append(formatted(releaseManager: value))
        }

        sections.forEach {
            output.append($0.output)
        }

        if let value = footer {
            output.append(value)
        }

        return output
    }

    // Normalizes input/removes
    private static func filteredLines(input: String, using transformers: [Transformer]) -> [String] {
        // Input must be sorted for regex to remove consecutive matching lines (cherry-picks)
        let sortedInput = input
            .components(separatedBy: "\n")
            .sorted(by: "@@@(.*)@@@")
            .joined(separator: "\n")

        return transformers
            .reduce(sortedInput) { $1.transform(text: $0) }
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
    }

    private func version(_ version: String) -> String {
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
