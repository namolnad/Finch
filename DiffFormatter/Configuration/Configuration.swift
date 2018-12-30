//
//  Configuration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configuration: Decodable {
    enum CodingKeys: String, CodingKey {
        case contributorsConfig
        case delimiterConfig
        case footer
        case gitConfig
        case header
        case sectionInfos
    }

    private(set) var contributorsConfig: ContributorsConfiguration
    private(set) var currentDirectory: String = ""
    private(set) var delimiterConfig: DelimiterConfiguration
    private(set) var footer: String?
    private(set) var gitConfig: GitConfiguration
    private(set) var header: String?
    private(set) var sectionInfos: [Section.Info]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        contributorsConfig = container.decode(forKey: .contributorsConfig, default: .blank)
        delimiterConfig = container.decode(forKey: .delimiterConfig, default: .blank)
        footer = container.optionalDecode(forKey: .footer)
        gitConfig = container.decode(forKey: .gitConfig, default: .default)
        header = container.optionalDecode(forKey: .header)
        sectionInfos = container.decode(forKey: .sectionInfos, default: [])
    }

    init(
        contributorsConfig: ContributorsConfiguration = .blank,
        sectionInfos: [Section.Info] = [],
        footer: String? = nil,
        delimiterConfig: DelimiterConfiguration = .blank,
        gitConfig: GitConfiguration = .blank,
        header: String? = nil) {
        self.contributorsConfig = contributorsConfig
        self.delimiterConfig = delimiterConfig
        self.footer = footer
        self.gitConfig = gitConfig
        self.header = header
        self.sectionInfos = sectionInfos
    }
}

extension Configuration {
    var contributors: [Contributor] {
        return contributorsConfig.contributors
    }

    var contributorHandlePrefix: String {
        return contributorsConfig.contributorHandlePrefix ?? ""
    }

    var gitExecutablePath: String? {
        return gitConfig.executablePath
    }

    var gitBranchPrefix: String {
        return gitConfig.branchPrefix ?? ""
    }
}

extension Configuration {
    mutating func update(with otherConfig: Configuration) {
        // Sections
        if !otherConfig.sectionInfos.isEmpty {
            self.sectionInfos = otherConfig.sectionInfos
        }

        // Header & Footer
        if let value = otherConfig.header {
            self.header = value
        }

        if let value = otherConfig.footer {
            self.footer = value
        }

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
}

extension Configuration {
    static func `default`(currentDirectory: String) -> Configuration {
        var config = Configuration(
            contributorsConfig: .default,
            sectionInfos: .default,
            delimiterConfig: .default,
            gitConfig: .default
        )
        config.currentDirectory = currentDirectory

        return config
    }
}

extension Configuration {
    var isBlank: Bool {
        return delimiterConfig.isBlank &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true) &&
            gitConfig.isBlank &&
            (header?.isEmpty == true) &&
            contributorsConfig.isBlank &&
            currentDirectory.isEmpty
    }
}
