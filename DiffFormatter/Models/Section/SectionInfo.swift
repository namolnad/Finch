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
        guard let titleMatch = matches(pattern: "%%%(.*)%%%", body: line).first, titleMatch.numberOfRanges > 1 else {
                return nil // TODO: - Throw and warn of misconfiguration
        }
        guard let tagsMatch = matches(pattern: "&&&(.*)&&&", body: line).first, tagsMatch.numberOfRanges > 1 else {
                return nil // TODO: - Throw and warn of misconfiguration
        }

        return SectionInfo(
            title: .init(range: titleMatch.range(at: 1), in: line),
            tags: Set(String(range: tagsMatch.range(at: 1), in: line).components(separatedBy: ","))
        )
    }
}

extension Array where Element == SectionInfo {
    static let defaultSectionInfos: [SectionInfo] = [
        .defaultFeaturesInfo,
        .init(title: "Bug Fixes", tags: ["bugfix", "cleanup", "bug fix", "bug"]),
        .init(title: "Platform Improvements", tags: ["platform", "tooling", "upgrade"]),
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
