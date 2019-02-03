//
//  Configuration.swift
//  DiffFormatterCore
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct Configuration: Decodable {
    enum CodingKeys: String, CodingKey {
        case contributorsConfig
        case delimiterConfig
        case footer
        case formatString
        case gitConfig
        case header
        case sectionInfos
        case resolutionCommandsConfig
    }

    public private(set) var contributorsConfig: ContributorsConfiguration
    public private(set) var projectDir: String = ""
    public private(set) var delimiterConfig: DelimiterConfiguration
    public private(set) var footer: String?
    public private(set) var formatTemplate: FormatTemplate?
    public private(set) var gitConfig: GitConfiguration
    public private(set) var header: String?
    public private(set) var sectionInfos: [SectionInfo]
    public private(set) var resolutionCommandsConfig: ResolutionCommandsConfiguration

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.contributorsConfig = container.decode(forKey: .contributorsConfig, default: .blank)
        self.delimiterConfig = container.decode(forKey: .delimiterConfig, default: .blank)
        self.footer = container.optionalDecode(forKey: .footer)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.gitConfig = container.decode(forKey: .gitConfig, default: .default)
        self.header = container.optionalDecode(forKey: .header)
        self.sectionInfos = container.decode(forKey: .sectionInfos, default: [])
        self.resolutionCommandsConfig = container.decode(forKey: .resolutionCommandsConfig, default: .blank)
    }

    public init(
        contributorsConfig: ContributorsConfiguration = .blank,
        sectionInfos: [SectionInfo] = [],
        footer: String? = nil,
        formatTemplate: FormatTemplate? = nil,
        delimiterConfig: DelimiterConfiguration = .blank,
        gitConfig: GitConfiguration = .blank,
        header: String? = nil,
        resolutionCommandsConfig: ResolutionCommandsConfiguration = .blank) {
        self.contributorsConfig = contributorsConfig
        self.delimiterConfig = delimiterConfig
        self.footer = footer
        self.formatTemplate = formatTemplate
        self.gitConfig = gitConfig
        self.header = header
        self.sectionInfos = sectionInfos
        self.resolutionCommandsConfig = resolutionCommandsConfig
    }
}

extension Configuration {
    public var contributors: [Contributor] {
        return contributorsConfig.contributors
    }

    public var contributorHandlePrefix: String {
        return contributorsConfig.contributorHandlePrefix ?? ""
    }

    public var gitExecutablePath: String? {
        return gitConfig.executablePath
    }

    public var gitBranchPrefix: String {
        return gitConfig.branchPrefix ?? ""
    }
}

extension Configuration {
    public mutating func update(with otherConfig: Configuration) {
        // Commands
        if !otherConfig.resolutionCommandsConfig.isBlank {
            if let value = otherConfig.resolutionCommandsConfig.buildNumber {
                self.resolutionCommandsConfig = .init(
                    buildNumber: value,
                    versions: self.resolutionCommandsConfig.versions
                )
            }
            if let value = otherConfig.resolutionCommandsConfig.versions {
                self.resolutionCommandsConfig = .init(
                    buildNumber: self.resolutionCommandsConfig.buildNumber,
                    versions: value
                )
            }
        }

        // Sections
        if !otherConfig.sectionInfos.isEmpty {
            self.sectionInfos = otherConfig.sectionInfos
        }

        if let value = otherConfig.formatTemplate {
            self.formatTemplate = value
        }

        // Header & Footer
        updateHeaderFooter(otherConfig: otherConfig)

        // Contributors configuration
        if !otherConfig.contributors.isEmpty {
            self.contributorsConfig = .init(
                contributors: otherConfig.contributors,
                contributorHandlePrefix: self.contributorsConfig.contributorHandlePrefix
            )
        }

        if let value = otherConfig.contributorsConfig.contributorHandlePrefix {
            self.contributorsConfig = .init(
                contributors: self.contributorsConfig.contributors,
                contributorHandlePrefix: value
            )
        }

        // Delimiter configuration
        if !otherConfig.delimiterConfig.input.isBlank {
            self.delimiterConfig = .init(
                input: otherConfig.delimiterConfig.input,
                output: self.delimiterConfig.output
            )
        }

        if !otherConfig.delimiterConfig.output.isBlank {
            self.delimiterConfig = .init(
                input: self.delimiterConfig.input,
                output: otherConfig.delimiterConfig.output
            )
        }

        // Git configuration
        if let value = otherConfig.gitConfig.branchPrefix {
            self.gitConfig = .init(
                branchPrefix: value,
                executablePath: self.gitConfig.executablePath,
                repoBaseUrl: self.gitConfig.repoBaseUrl
            )
        }

        if let value = otherConfig.gitConfig.executablePath {
            self.gitConfig = .init(
                branchPrefix: self.gitConfig.branchPrefix,
                executablePath: value,
                repoBaseUrl: self.gitConfig.repoBaseUrl
            )
        }

        if case let value = otherConfig.gitConfig.repoBaseUrl, !value.isEmpty {
            self.gitConfig = .init(
                branchPrefix: self.gitConfig.branchPrefix,
                executablePath: self.gitConfig.executablePath,
                repoBaseUrl: value
            )
        }
    }

    private mutating func updateHeaderFooter(otherConfig: Configuration) {
        if let value = otherConfig.header {
            self.header = value
        }

        if let value = otherConfig.footer {
            self.footer = value
        }
    }
}

extension Configuration {
    public static func `default`(projectDir: String) -> Configuration {
        var config = Configuration(
            contributorsConfig: .default,
            sectionInfos: .default,
            delimiterConfig: .default,
            gitConfig: .default
        )
        config.projectDir = projectDir

        return config
    }
}

extension Configuration {
    public var isBlank: Bool {
        return delimiterConfig.isBlank &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true) &&
            (formatTemplate?.outputtables.isEmpty == true) &&
            gitConfig.isBlank &&
            (header?.isEmpty == true) &&
            contributorsConfig.isBlank &&
            projectDir.isEmpty &&
            resolutionCommandsConfig.isBlank
    }
}
