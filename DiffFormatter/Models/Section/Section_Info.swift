//
//  Section_Info.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/14/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Section {
    struct Info {
        enum CodingKeys: String, CodingKey {
            case capitalizesMessage
            case excluded
            case formatString
            case tags
            case title
        }

        let capitalizesMessage: Bool
        let excluded: Bool
        let formatTemplate: Section.Line.FormatTemplate?
        let tags: Set<String>
        let title: String

        init(capitalizesMessage: Bool,
             excluded: Bool = false,
             formatTemplate: Section.Line.FormatTemplate?,
             tags: [String],
             title: String) {
            self.capitalizesMessage = capitalizesMessage
            self.excluded = excluded
            self.formatTemplate = formatTemplate
            self.tags = Set(tags)
            self.title = title
        }
    }

}

extension Section.Info: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let formatString: String? = container.optionalDecode(forKey: .formatString)
        self.capitalizesMessage = container.decode(forKey: .capitalizesMessage, default: false)
        self.excluded = container.decode(forKey: .excluded, default: false)
        self.formatTemplate = Section.Line.FormatTemplate(formatString: formatString)
        self.tags = try container.decode(forKey: .tags)
        self.title = try container.decode(forKey: .title)
    }
}

extension Section.Info {
    fileprivate static let `default`: Section.Info = .init(
        capitalizesMessage: false,
        formatTemplate: .default,
        tags: ["*"],
        title: "Features"
    )

    fileprivate static let bugs: Section.Info = .init(
        capitalizesMessage: false,
        formatTemplate: .default,
        tags: ["bugfix", "bug fix", "bug"],
        title: "Bug Fixes"
    )
}

extension Array where Element == Section.Info {
    static let `default`: [Section.Info] = [
        .default,
        .bugs
    ]
}
