//
//  OutputGenerator.swift
//  DiffFormatterApp.swift
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import class Basic.Process
import DiffFormatterCore

struct OutputGenerator {
    typealias Options = GenerateCommand.Options

    private let version: String?
    private let releaseManager: Contributor?
    private let sections: [Section]
    private let footer: String?
    private let header: String?
    private let contributorHandlePrefix: String

    init(options: Options, app: App, env: Environment) throws {
        let configuration = app.configuration
        let rawGitLog: String = try type(of: self).log(options: options, app: app, env: env)
        let version: String? = try type(of: self).versionHeader(options: options, app: app, env: env)
        let releaseManager: Contributor? = type(of: self).releaseManager(options: options, configuration: configuration)

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

    private static func versionHeader(options: Options, app: App, env: Environment) throws -> String? {
        guard !options.noShowVersion else {
            return nil
        }

        let versionHeader: String = options.versions.new.description

        if let buildNumber = options.buildNumber {
            return versionHeader + " (\(buildNumber))"
        }

        guard
            let args = app.configuration.resolutionCommandsConfig.buildNumber,
            !args.isEmpty,
            let buildNumber = try getBuildNumber(
                for: options.versions.new,
                projectDir: app.configuration.projectDir,
                using: args,
                environment: env
                )?.trimmingCharacters(in: .whitespacesAndNewlines) else {
                    return versionHeader
        }

        return versionHeader + " (\(buildNumber))"
    }

    private static func getBuildNumber(
        for newVersion: Version,
        projectDir: String,
        using args: [String],
        environment: Environment) throws -> String? {
        guard !args.isEmpty else {
            return nil
        }

        let env: Environment = environment.merging([
            "NEW_VERSION": "\(newVersion)",
            "PROJECT_DIR": "\(projectDir)"
        ]) { $1 }

        let process: Process = .init(
            arguments: args,
            environment: env
        )

        try process.launch()
        try process.waitUntilExit()

        if let result = process.result {
            return try result.utf8Output()
        } else {
            return nil
        }
    }

    private static func log(options: Options, app: App, env: Environment) throws -> String {
        if let log = options.gitLog {
            return log
        }

        let git = Git(configuration: app.configuration, env: env)

        if !options.noFetch {
            app.print("Fetching origin", kind: .info)
            try git.fetch()
        }

        app.print("Generating log", kind: .info)

        return try git.log(oldVersion: options.versions.old, newVersion: options.versions.new)
    }

    private static func releaseManager(options: Options, configuration: Configuration) -> Contributor? {
        guard let email = options.releaseManager else {
            return nil
        }

        return configuration.contributors.first { $0.email == email }
    }
}
