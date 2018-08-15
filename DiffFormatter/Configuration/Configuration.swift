//
//  Configuration.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Configuration {
    enum Component: String {
        case users
        case sectionInfos = "section_infos"
        case footer
    }

    let users: [User]

    let sectionInfos: [SectionInfo]

    let footer: String?
}

extension Configuration {
    var isEmpty: Bool {
        return users.isEmpty &&
            sectionInfos.isEmpty &&
            (footer?.isEmpty == true)
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
    static let empty: Configuration = .init(users: [], sectionInfos: [], footer: nil)

    static let `default`: Configuration = .init(users: [], sectionInfos: .defaultSectionInfos, footer: nil)
}
