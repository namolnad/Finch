//
//  SectionInfo.swift
//  DiffFormatterCore
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterUtilities
import Foundation

public struct SectionInfo {
    enum CodingKeys: String, CodingKey {
        case capitalizesMessage
        case excluded
        case formatString
        case tags
        case title
    }

    public let capitalizesMessage: Bool
    public let excluded: Bool
    public let formatTemplate: FormatTemplate?
    public let tags: Set<String>
    public let title: String

    public init(capitalizesMessage: Bool,
                excluded: Bool = false,
                formatTemplate: FormatTemplate?,
                tags: [String],
                title: String) {
        self.capitalizesMessage = capitalizesMessage
        self.excluded = excluded
        self.formatTemplate = formatTemplate
        self.tags = Set(tags)
        self.title = title
    }
}

//extension Section {
//    public init(config: Configuration, info: SectionInfo, linesComponents: [LineComponents]) {
//        self.init(configuration: config, info: info, linesComponents: linesComponents)
//    }
//
//}

extension SectionInfo: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.capitalizesMessage = container.decode(forKey: .capitalizesMessage, default: false)
        self.excluded = container.decode(forKey: .excluded, default: false)
        self.formatTemplate = FormatTemplate(formatString: formatString)
        self.tags = try container.decode(forKey: .tags)
        self.title = try container.decode(forKey: .title)
    }
}

extension SectionInfo {
    fileprivate static let `default`: SectionInfo = .init(
        capitalizesMessage: false,
        formatTemplate: .default,
        tags: ["*"],
        title: "Features"
    )

    fileprivate static let bugs: SectionInfo = .init(
        capitalizesMessage: false,
        formatTemplate: .default,
        tags: ["bugfix", "bug fix", "bug"],
        title: "Bug Fixes"
    )
}

extension Array where Element == SectionInfo {
    static let `default`: [SectionInfo] = [
        .default,
        .bugs
    ]
}
