//
//  Configuration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    let usersConfig: UsersConfiguration
    let delimiterConfig: DelimiterConfiguration
    let sectionInfos: [SectionInfo]
    let footer: String?
    var users: [User] {
        return usersConfig.users
    }

    var userHandlePrefix: String? {
        return usersConfig.userHandlePrefix
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        usersConfig = (try? container.decode(UsersConfiguration.self, forKey: .usersConfig)) ?? .empty
        sectionInfos = (try? container.decode([SectionInfo].self, forKey: .sectionInfos)) ?? []
        footer = try? container.decode(String.self, forKey: .footer)
        delimiterConfig = (try? container.decode(DelimiterConfiguration.self, forKey: .delimiterConfig)) ?? .empty
    }

    init(usersConfig: UsersConfiguration = .empty, sectionInfos: [SectionInfo] = [], footer: String? = nil, delimiterConfig: DelimiterConfiguration = .empty) {
        self.usersConfig = usersConfig
        self.sectionInfos = sectionInfos
        self.footer = footer
        self.delimiterConfig = delimiterConfig
    }
}

extension Configuration {
    var isEmpty: Bool {
        return users.isEmpty &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true) &&
            delimiterConfig.input.isEmpty &&
            delimiterConfig.output.isEmpty
    }

    mutating func update(with otherConfig: Configuration) {
        self = modifiedConfig(withNonEmptyComponentsFrom: otherConfig)
    }

    func modifiedConfig(withNonEmptyComponentsFrom otherConfig: Configuration) -> Configuration {
        var users: [User] = self.users
        var userHandlePrefix = self.userHandlePrefix
        var sectionInfos: [SectionInfo] = self.sectionInfos
        var footer: String? = self.footer
        var inputDelimiters: DelimiterPair = delimiterConfig.input
        var outputDelimiters: DelimiterPair = delimiterConfig.output

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

        if let value = otherConfig.userHandlePrefix {
            userHandlePrefix = value
        }

        return .init(usersConfig: .init(users: users, userHandlePrefix: userHandlePrefix), sectionInfos: sectionInfos, footer: footer, delimiterConfig: .init(input: inputDelimiters, output: outputDelimiters))
    }
}

extension Configuration {
    static let empty: Configuration = .init()

    static let `default`: Configuration = .init(usersConfig: .default,sectionInfos: .default, delimiterConfig: .default)
}
