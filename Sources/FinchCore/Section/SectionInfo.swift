//
//  SectionInfo.swift
//  FinchCore
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchUtilities
import Foundation

public struct SectionInfo {
    public let capitalizesMessage: Bool
    public let excluded: Bool
    public let formatTemplate: FormatTemplate?
    public let tags: [String]
    public let title: String
}

/// :nodoc:
extension SectionInfo: Codable {
    enum CodingKeys: String, CodingKey {
        case capitalizesMessage = "capitalizes_message"
        case excluded
        case formatString = "format_string"
        case tags
        case title
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.capitalizesMessage = container.decode(forKey: .capitalizesMessage, default: false)
        self.excluded = container.decode(forKey: .excluded, default: false)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.tags = try container.decode(forKey: .tags)
        self.title = try container.decode(forKey: .title)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(formatTemplate?.formatString, forKey: .formatString)
        try container.encode(capitalizesMessage, forKey: .capitalizesMessage)
        try container.encode(excluded, forKey: .excluded)
        try container.encode(tags, forKey: .tags)
        try container.encode(title, forKey: .title)
    }
}

extension SectionInfo {
    fileprivate static let `default`: SectionInfo = .init(
        capitalizesMessage: false,
        excluded: false,
        formatTemplate: .default,
        tags: ["*"],
        title: "Features"
    )

    fileprivate static let bugs: SectionInfo = .init(
        capitalizesMessage: false,
        excluded: false,
        formatTemplate: .default,
        tags: ["bugfix", "bug fix", "bug"],
        title: "Bug Fixes"
    )
}

/// :nodoc:
extension Array where Element == SectionInfo {
    static let `default`: [SectionInfo] = [
        .default,
        .bugs
    ]
}
