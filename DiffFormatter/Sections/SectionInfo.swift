//
//  SectionInfo.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct SectionInfo: Hashable {
    var hashValue: Int {
        return title.hashValue
    }

    let title: String
    let tags: Set<String>
}

extension SectionInfo {
    static let defaultFeaturesInfo: SectionInfo = .init(title: "Features", tags: ["*"])

    static func from(line: String) -> SectionInfo? {
        guard let titleNSRange = matches(pattern: "%%%(.*)%%%", body: line).first?.range(at: 1),
            let titleRange = Range(titleNSRange, in: line) else {
                return nil  // Should throw here and ensure range(at: 1) will be valid
        }
        guard let tagsNSRange = matches(pattern: "&&&(.*)&&&", body: line).first?.range(at: 1),
            let tagsRange = Range(tagsNSRange, in: line) else {
                return nil // Should throw here and ensure range(at: 1) will be valid
        }

        return SectionInfo(
            title: String(line[titleRange]),
            tags: Set(String(line[tagsRange]).components(separatedBy: " "))
        )
    }
}

extension Array where Element == SectionInfo {
    static let defaultSectionInfos: [SectionInfo] = [
        .init(title: "Bug Fixes", tags: ["bugfix", "cleanup", "bug fix", "bug"]),
        .init(title: "Platform Improvements", tags: ["platform", "tooling", "upgrade"]),
        SectionInfo.defaultFeaturesInfo,
    ]

    static func from(data: Data) -> [SectionInfo] {
        guard let string = String(data: data, encoding: .utf8) else {
            return []
        }
        return string
            .components(separatedBy: "\n")
            .compactMap(SectionInfo.from)
    }
}
