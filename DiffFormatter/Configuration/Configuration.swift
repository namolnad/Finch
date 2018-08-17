//
//  Configuration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    let users: [User]
    let sectionInfos: [SectionInfo]
    let footer: String?
    let delimiterConfig: DelimiterConfiguration

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        users = (try? container.decode([User].self, forKey: .users)) ?? []
        sectionInfos = (try? container.decode([SectionInfo].self, forKey: .sectionInfos)) ?? []
        footer = try? container.decode(String.self, forKey: .footer)
        delimiterConfig = (try? container.decode(DelimiterConfiguration.self, forKey: .delimiterConfig)) ?? .empty
    }

    init(users: [User] = [], sectionInfos: [SectionInfo] = [], footer: String? = nil, delimiterConfig: DelimiterConfiguration = .empty) {
        self.users = users
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

        return .init(users: users, sectionInfos: sectionInfos, footer: footer, delimiterConfig: .init(input: inputDelimiters, output: outputDelimiters))
    }
}

extension Configuration {
    static let empty: Configuration = .init()

    static let `default`: Configuration = .init(sectionInfos: .default, delimiterConfig: .default)
}
