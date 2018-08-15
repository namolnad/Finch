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
        case sectionInfos
    }

    let users: [User]

    let sectionInfos: [SectionInfo]
}
