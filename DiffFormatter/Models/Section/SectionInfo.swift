//
//  SectionInfo.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct SectionInfo: Codable, Hashable {
    let title: String
    let tags: Set<String>

    var hashValue: Int {
        return title.hashValue ^
            tags.hashValue
    }
}

extension SectionInfo {
    fileprivate static let `default`: SectionInfo = .init(title: "Features", tags: ["*"])
    fileprivate static let bugs: SectionInfo = .init(title: "Bug Fixes", tags: ["bugfix", "bug fix", "bug"])
}

extension Array where Element == SectionInfo {
    static let `default`: [SectionInfo] = [
        .default,
        .bugs
    ]
}
