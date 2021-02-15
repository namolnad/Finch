//
//  ChangeLogModel.swift
//  FinchApp.swift
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchCore
import Version

/// A protocol defining the model for changelog creation/formatting.
protocol ChangeLogModelType {
    /// Returns the old and new versions being compared.
    func versions(app: App) throws -> (old: Version, new: Version)

    /// Returns the transformed and formatted changelog.
    func changeLog(options: CompareCommand.Options, app: App) throws -> String
}

/// A concrete type conforming to `ChangeLogModelType` protocol.
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

    /// See `ChangeLogModelType.changeLog(options:app:)` for definition.
    func changeLog(options: Options, app: App) throws -> String {
        let outputInfo: OutputInfo = try self.outputInfo(for: options, app: app)

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

        if options.useNewlineChar {
            output = output.replacingOccurrences(of: "\n", with: "\\n")
        }

        return output
    }

    /// See `ChangeLogModelType.versions(app:)` for definition.
    func versions(app: App) throws -> (old: Version, new: Version) {
        try resolver.versions(
            from: try service.versionsString(app: app)
        )
    }

    private func outputInfo(for options: Options, app: App) throws -> OutputInfo {
        let configuration = app.configuration
        let rawChangeLog: String = try service.changeLog(options: options, app: app)
        let version: String? = try versionHeader(options: options, app: app)
        let releaseManager: Contributor? = self.releaseManager(options: options, configuration: configuration)

        let linesComponents = type(of: self)
            .filteredLines(input: rawChangeLog, using: .default(for: configuration))
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
            guard
                let index = tagToIndex[tag],
                case let section = sections[index],
                options.requiredTags.isSubset(of: components.tags)
            else { continue }

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
        """

        # \(version)

        """
    }

    private func formatted(contributorHandlePrefix: String, releaseManager: Contributor) -> String {
        """

        ### Release Manager

         - \(contributorHandlePrefix)\(releaseManager.handle)

        """
    }

    private func versionHeader(options: Options, app: App) throws -> String? {
        guard !options.noShowVersion else {
            return nil
        }

        let versionHeader: String = options.versions.new.description

        guard let buildNumber = try service.buildNumber(options: options, app: app) else {
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
