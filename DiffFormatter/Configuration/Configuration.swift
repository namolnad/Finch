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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        users = (try? container.decode([User].self, forKey: .users)) ?? []
        sectionInfos = (try? container.decode([SectionInfo].self, forKey: .sectionInfos)) ?? []
        footer = try? container.decode(String.self, forKey: .footer)
    }

    init(users: [User] = [], sectionInfos: [SectionInfo] = [], footer: String? = nil) {
        self.users = users
        self.sectionInfos = sectionInfos
        self.footer = footer
    }
}

extension Configuration {
    var isEmpty: Bool {
        return users.isEmpty &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true)
    }

    mutating func update(with otherConfig: Configuration) {
        self = modifiedConfig(withNonEmptyComponentsFrom: otherConfig)
    }

    func modifiedConfig(withNonEmptyComponentsFrom otherConfig: Configuration) -> Configuration {
        var users: [User] = self.users
        var sectionInfos: [SectionInfo] = self.sectionInfos
        var footer: String? = self.footer

        if !otherConfig.users.isEmpty {
            users = otherConfig.users
        }

        if !otherConfig.sectionInfos.isEmpty {
            sectionInfos = otherConfig.sectionInfos
        }

        if let value = otherConfig.footer {
            footer = value
        }

        return .init(users: users, sectionInfos: sectionInfos, footer: footer)
    }
}

extension Configuration {
    static let empty: Configuration = .init()

    static let `default`: Configuration = .init(sectionInfos: .default)
}
