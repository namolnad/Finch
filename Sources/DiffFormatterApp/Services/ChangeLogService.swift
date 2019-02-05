//
//  ChangeLogService.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import class Basic.Process
import DiffFormatterCore

protocol ChangeLogGenerating {
    func changeLog(options: GenerateCommand.Options, app: App, env: Environment) throws -> String
}

final class ChangeLogService: ChangeLogGenerating {
    typealias Options = GenerateCommand.Options

    private var version: String?
    private var releaseManager: Contributor?
    private var sections: [Section] = []
    private var footer: String?
    private var header: String?
    private var contributorHandlePrefix: String = ""

    private let buildNumberProvider: BuildNumberProviding
    private let logProvider: LogProviding

    init(buildNumberProvider: BuildNumberProviding = BuildNumberService(), logProvider: LogProviding = LogService()) {
        self.buildNumberProvider = buildNumberProvider
        self.logProvider = logProvider
    }

    private func prepare(options: Options, app: App, env: Environment) throws {
        let configuration = app.configuration
        let rawGitLog: String = try logProvider.log(options: options, app: app, env: env)
        let version: String? = try versionHeader(options: options, app: app, env: env)
        let releaseManager: Contributor? = self.releaseManager(options: options, configuration: configuration)

        let transformerFactory = TransformerFactory(configuration: configuration)

        let linesComponents = type(of: self)
            .filteredLines(input: rawGitLog, using: transformerFactory.initialTransformers)
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
        self.sections = sections.filter { !$0.info.excluded && !$0.linesComponents.isEmpty }
        self.footer = configuration.footer
        self.header = configuration.header
        self.contributorHandlePrefix = configuration.contributorHandlePrefix
    }

    func changeLog(options: Options, app: App, env: Environment) throws -> String {
        try prepare(options: options, app: app, env: env)

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

    private func versionHeader(options: Options, app: App, env: Environment) throws -> String? {
        guard !options.noShowVersion else {
            return nil
        }

        let versionHeader: String = options.versions.new.description

        guard let buildNumber = try buildNumberProvider.buildNumber(options: options, app: app, env: env) else {
            return versionHeader
        }

        return versionHeader + " (\(buildNumber))"
    }

    private func releaseManager(options: Options, configuration: Configuration) -> Contributor? {
        guard let email = options.releaseManager else {
            return nil
        }

        return configuration.contributors.first { $0.email == email }
    }
}
