//
//  Utilities_OutputGenerator.swift
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
        private let header: String?
        private let contributorHandlePrefix: String
    }
}

extension Utilities.OutputGenerator {
    init(configuration: Configuration, rawDiff: String, version: String?, releaseManager: Contributor?) {
        let transformerFactory = TransformerFactory(configuration: configuration)

        let linesComponents = type(of: self)
            .filteredLines(input: rawDiff, using: transformerFactory.initialTransformers)
            .compactMap { Section.Line.Components(rawLine: $0, configuration: configuration) }

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
        return transformers
            .reduce(input) { $1.transform(text: $0) }
            .components(separatedBy: "\n")
            .sorted(by: "@@@(.*)@@@")
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
