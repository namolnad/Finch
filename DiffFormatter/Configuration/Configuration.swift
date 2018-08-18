//
//  Configuration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    var users: [User] {
        return usersConfig.users
    }

    var userHandlePrefix: String {
        return usersConfig.userHandlePrefix ?? ""
    }

    var gitExecutablePath: String? {
        return gitConfig.executablePath
    }

    var gitBranchPrefix: String {
        return gitConfig.branchPrefix ?? ""
    }

    let delimiterConfig: DelimiterConfiguration
    let sectionInfos: [SectionInfo]
    let footer: String?
    private let gitConfig: GitConfiguration
    private let usersConfig: UsersConfiguration
    private(set) var currentDirectory: String = ""

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        usersConfig = (try? container.decode(UsersConfiguration.self, forKey: .usersConfig)) ?? .empty
        sectionInfos = (try? container.decode([SectionInfo].self, forKey: .sectionInfos)) ?? []
        footer = try? container.decode(String.self, forKey: .footer)
        delimiterConfig = (try? container.decode(DelimiterConfiguration.self, forKey: .delimiterConfig)) ?? .empty
        gitConfig = (try? container.decode(GitConfiguration.self, forKey: .gitConfig)) ?? .empty
    }

    init(usersConfig: UsersConfiguration = .empty, sectionInfos: [SectionInfo] = [], footer: String? = nil, delimiterConfig: DelimiterConfiguration = .empty, gitConfig: GitConfiguration = .empty) {
        self.usersConfig = usersConfig
        self.sectionInfos = sectionInfos
        self.footer = footer
        self.delimiterConfig = delimiterConfig
        self.gitConfig = gitConfig
    }
}

extension Configuration {
    var isEmpty: Bool {
        return users.isEmpty &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true) &&
            delimiterConfig.input.isEmpty &&
            delimiterConfig.output.isEmpty &&
            userHandlePrefix.isEmpty &&
            gitBranchPrefix.isEmpty &&
            (gitExecutablePath?.isEmpty == true)
    }

    mutating func update(with otherConfig: Configuration) {
        self = modifiedConfig(withNonEmptyComponentsFrom: otherConfig)
    }

    func modifiedConfig(withNonEmptyComponentsFrom otherConfig: Configuration) -> Configuration {
        var users = self.users
        var userHandlePrefix = self.userHandlePrefix
        var sectionInfos = self.sectionInfos
        var footer = self.footer
        var inputDelimiters = delimiterConfig.input
        var outputDelimiters = delimiterConfig.output
        var gitBranchPrefix = self.gitBranchPrefix
        var gitExecutablePath = self.gitExecutablePath

        if !otherConfig.users.isEmpty {
            users = otherConfig.users
        }

        if !otherConfig.sectionInfos.isEmpty {
            sectionInfos = otherConfig.sectionInfos
        }

        if let value = otherConfig.footer {
            footer = value
        }

        if !otherConfig.delimiterConfig.input.isEmpty {
            inputDelimiters = otherConfig.delimiterConfig.input
        }

        if !otherConfig.delimiterConfig.output.isEmpty {
            outputDelimiters = otherConfig.delimiterConfig.output
        }

        if let value = otherConfig.usersConfig.userHandlePrefix {
            userHandlePrefix = value
        }

        if let value = otherConfig.gitConfig.branchPrefix {
            gitBranchPrefix = value
        }

        if let value = otherConfig.gitConfig.executablePath {
            gitExecutablePath = value
        }

        return .init(
            usersConfig: .init(users: users, userHandlePrefix: userHandlePrefix),
            sectionInfos: sectionInfos,
            footer: footer,
            delimiterConfig: .init(input: inputDelimiters, output: outputDelimiters),
            gitConfig: .init(branchPrefix: gitBranchPrefix, executablePath: gitExecutablePath)
        )
    }
}

extension Configuration {
    static let empty: Configuration = .init()

    static func `default`(currentDirectory: String) -> Configuration {
        var config = Configuration(
            usersConfig: .default,
            sectionInfos: .default,
            delimiterConfig: .default,
            gitConfig: .default
        )
        config.currentDirectory = currentDirectory

        return config
    }
}
