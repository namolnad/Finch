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
            case formatString
            case tags
            case title
        }

        private let formatString: String
        let tags: Set<String>
        let title: String

        init(formatString: String, tags: [String], title: String) {
            self.formatString = formatString
            self.tags = Set(tags)
            self.title = title
        }
    }

}

extension Section.Info {
    var format: [LineOutputtable] {
        return formatString.lineOutputtables
    }
}

extension Section.Info: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.formatString = container.decode(forKey: .formatString, default: .defaultFormatString)
        self.tags = try container.decode(forKey: .tags)
        self.title = try container.decode(forKey: .title)
    }
}

extension Section.Info {
    fileprivate static let `default`: Section.Info = .init(formatString: .defaultFormatString, tags: ["*"], title: "Features")
    fileprivate static let bugs: Section.Info = .init(formatString: .defaultFormatString, tags: ["bugfix", "bug fix", "bug"], title: "Bug Fixes")
}

extension Array where Element == Section.Info {
    static let `default`: [Section.Info] = [
        .default,
        .bugs
    ]
}

private extension String {
    static let defaultFormatString = " - <<tags>> <<message>> — <<commit_type_hyperlink>> — <<contributor_handle>>"

    // Walk along format string to gather typed LineOutputtable's
    var lineOutputtables: [LineOutputtable] {
        var components: [String] = []
        var component: String = ""
        if let value = first {
            component.append(value)
        }

        func flush() {
            guard !component.isEmpty else { return }
            components.append(component)
            component = ""
        }

        for idx in indices.dropFirst().dropLast() {
            let nextEqualToCurrent = self[index(after: idx)] == self[idx]
            let currentEqualToPrev = self[index(before: idx)] == self[idx]
            let currentIsOpening = self[idx] == "<"
            let currentIsClosing = self[idx] == ">"

            if nextEqualToCurrent && currentIsOpening {
                flush()
            }

            component.append(self[idx])

            if currentEqualToPrev && currentIsClosing {
                flush()
            }
        }

        // Clean up last closing
        if !component.isEmpty {
            component.append(self[index(before: endIndex)])
            flush()
        }

        var transformedComp: [LineOutputtable] = []

        for comp in components {
            switch comp {
            case "<<\(LineFormatComponent.commitTypeHyperlink.rawValue)>>": transformedComp.append(LineFormatComponent.commitTypeHyperlink)
            case "<<\(LineFormatComponent.contributorEmail.rawValue)>>":
                transformedComp.append(LineFormatComponent.contributorEmail)
            case "<<\(LineFormatComponent.contributorHandle.rawValue)>>":
                transformedComp.append(LineFormatComponent.contributorHandle)
            case "<<\(LineFormatComponent.message.rawValue)>>":
                transformedComp.append(LineFormatComponent.message)
            case "<<\(LineFormatComponent.tags.rawValue)>>":
                transformedComp.append(LineFormatComponent.tags)
            case "<<\(LineFormatComponent.sha.rawValue)>>":
                transformedComp.append(LineFormatComponent.sha)
            default:
                transformedComp.append(comp)
            }
        }

        return transformedComp
    }
}
