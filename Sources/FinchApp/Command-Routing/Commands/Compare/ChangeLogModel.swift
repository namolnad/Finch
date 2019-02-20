//
//  ChangeLogModel.swift
//  FinchApp.swift
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import class Basic.Process
import FinchCore

/// A protocol defining the model for changelog creation/formatting.
protocol ChangeLogModelType {
    /// Returns the old and new versions being compared.
    func versions(app: App, env: Environment) throws -> (old: Version, new: Version)

    /// Returns the transformed and formatted changelog.
    func changeLog(options: CompareCommand.Options, app: App, env: Environment) throws -> String
}

/// A concrete type conforming to ChangeLogModelType protocol.
final class ChangeLogModel: ChangeLogModelType {
    /// :nodoc:
    typealias Options = CompareCommand.Options

    private struct OutputInfo {
        fileprivate var version: String?
        fileprivate var releaseManager: Contributor?
        fileprivate var sections: [Section] = []
        fileprivate var footer: String?
        fileprivate var header: String?
        fileprivate var contributorHandlePrefix: String = ""
    }

    private let resolver: VersionsResolving
    private let service: ChangeLogInfoServiceType

    /// :nodoc:
    init(resolver: VersionsResolving = VersionsResolver(), service: ChangeLogInfoServiceType = ChangeLogInfoService()) {
        self.resolver = resolver
        self.service = service
    }

    /// See `ChangeLogModelType.changeLog(options:app:env:)` for definition.
    func changeLog(options: Options, app: App, env: Environment) throws -> String {
        let outputInfo: OutputInfo = try self.outputInfo(for: options, app: app, env: env)

        var output = ""

        if let value = outputInfo.header {
            output.append(value)
        }

        if let value = outputInfo.version {
            output.append(version(value))
        }

        if let value = outputInfo.releaseManager {
            output.append(formatted(contributorHandlePrefix: outputInfo.contributorHandlePrefix, releaseManager: value))
        }

        outputInfo.sections.forEach {
            output.append($0.output)
        }

        if let value = outputInfo.footer {
            output.append(value)
        }

        return output
    }

    /// See `ChangeLogModelType.versions(app:env:)` for definition.
    func versions(app: App, env: Environment) throws -> (old: Version, new: Version) {
        return try resolver.versions(
            from: try service.versionsString(app: app, env: env)
        )
    }

    private func outputInfo(for options: Options, app: App, env: Environment) throws -> OutputInfo {
        let configuration = app.configuration
        let rawChangeLog: String = try service.changeLog(options: options, app: app, env: env)
        let version: String? = try versionHeader(options: options, app: app, env: env)
        let releaseManager: Contributor? = self.releaseManager(options: options, configuration: configuration)

        let transformers = TransformerFactory(configuration: configuration).initialTransformers

        let linesComponents = type(of: self)
            .filteredLines(input: rawChangeLog, using: transformers)
            .compactMap { rawLine in
                LineComponents(
                    rawLine: rawLine,
                    configuration: configuration,
                    normalizeTags: options.normalizeTags
                )
            }

        var sections: [Section] = configuration
            .formatConfig
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

        return .init(
            version: version,
            releaseManager: releaseManager,
            sections: sections.filter { !$0.info.excluded && !$0.linesComponents.isEmpty },
            footer: configuration.formatConfig.footer,
            header: configuration.formatConfig.header,
            contributorHandlePrefix: configuration.contributorsConfig.contributorHandlePrefix
        )
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

    private func formatted(contributorHandlePrefix: String, releaseManager: Contributor) -> String {
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

        guard let buildNumber = try service.buildNumber(options: options, app: app, env: env) else {
            return versionHeader
        }

        return versionHeader + " (\(buildNumber))"
    }

    private func releaseManager(options: Options, configuration: Configuration) -> Contributor? {
        guard let email = options.releaseManager else {
            return nil
        }

        return configuration.contributorsConfig.contributors.first { $0.emails.contains(email) }
    }
}
