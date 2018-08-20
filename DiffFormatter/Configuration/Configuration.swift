//
//  Configuration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    private(set) var delimiterConfig: DelimiterConfiguration
    private(set) var sectionInfos: [SectionInfo]
    private(set) var footer: String?
    private(set) var gitConfig: GitConfiguration
    private(set) var usersConfig: UsersConfiguration
    private(set) var currentDirectory: String = ""

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        usersConfig = (try? container.decode(UsersConfiguration.self, forKey: .usersConfig)) ?? .blank
        sectionInfos = (try? container.decode([SectionInfo].self, forKey: .sectionInfos)) ?? []
        footer = try? container.decode(String.self, forKey: .footer)
        delimiterConfig = (try? container.decode(DelimiterConfiguration.self, forKey: .delimiterConfig)) ?? .blank
        gitConfig = (try? container.decode(GitConfiguration.self, forKey: .gitConfig)) ?? .blank
    }

    init(usersConfig: UsersConfiguration = .blank, sectionInfos: [SectionInfo] = [], footer: String? = nil, delimiterConfig: DelimiterConfiguration = .blank, gitConfig: GitConfiguration = .blank) {
        self.usersConfig = usersConfig
        self.sectionInfos = sectionInfos
        self.footer = footer
        self.delimiterConfig = delimiterConfig
        self.gitConfig = gitConfig
    }
}

extension Configuration {
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
}

extension Configuration {
    mutating func update(with otherConfig: Configuration) {
        // Sections & Footer
        if !otherConfig.sectionInfos.isEmpty {
            self.sectionInfos = otherConfig.sectionInfos
        }

        if let value = otherConfig.footer {
            self.footer = value
        }

        // Users configuration
        if !otherConfig.users.isEmpty {
            self.usersConfig = UsersConfiguration(users: otherConfig.users, userHandlePrefix: self.usersConfig.userHandlePrefix)
        }

        if let value = otherConfig.usersConfig.userHandlePrefix {
            self.usersConfig = UsersConfiguration(users: self.usersConfig.users, userHandlePrefix: value)
        }

        // Delimiter configuration
        if !otherConfig.delimiterConfig.input.isBlank {
            self.delimiterConfig = DelimiterConfiguration(input: otherConfig.delimiterConfig.input, output: self.delimiterConfig.output)
        }

        if !otherConfig.delimiterConfig.output.isBlank {
            self.delimiterConfig = DelimiterConfiguration(input: self.delimiterConfig.input, output: otherConfig.delimiterConfig.output)
        }

        // Git configuration
        if let value = otherConfig.gitConfig.branchPrefix {
            self.gitConfig = GitConfiguration(branchPrefix: value, executablePath: self.gitConfig.executablePath)
        }

        if let value = otherConfig.gitConfig.executablePath {
            self.gitConfig = GitConfiguration(branchPrefix: self.gitConfig.branchPrefix, executablePath: value)
        }
    }
}

extension Configuration {
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

protocol Blankable {
    var isBlank: Bool { get }
}

extension Configuration {
    var isBlank: Bool {
        return delimiterConfig.isBlank &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true) &&
            gitConfig.isBlank &&
            usersConfig.isBlank &&
            currentDirectory.isEmpty
    }
}
