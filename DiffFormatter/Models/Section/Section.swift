//
//  Section.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/15/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Section: Codable {
    let info: SectionInfo
    var lines: [String]
}

extension Section {
    static func `default`(for info: SectionInfo) -> Section {
        return Section(info: info, lines: [])
    }
}
