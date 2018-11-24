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
            case formatString
            case tags
            case title
        }

        let capitalizesMessage: Bool
        private let formatString: String
        let tags: Set<String>
        let title: String

        init(capitalizesMessage: Bool, formatString: String, tags: [String], title: String) {
            self.capitalizesMessage = capitalizesMessage
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
        self.capitalizesMessage = container.decode(forKey: .capitalizesMessage, default: false)
        self.tags = try container.decode(forKey: .tags)
        self.title = try container.decode(forKey: .title)
    }
}

extension Section.Info {
    fileprivate static let `default`: Section.Info = .init(
        capitalizesMessage: false,
        formatString: .defaultFormatString,
        tags: ["*"],
        title: "Features"
    )

    fileprivate static let bugs: Section.Info = .init(
        capitalizesMessage: false,
        formatString: .defaultFormatString,
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
        func string(for formatComponent: Section.Line.FormatComponent) -> String {
            return formatComponent.rawValue
        }
        func format(component: Section.Line.FormatComponent) -> LineOutputtable {
            return component
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

        for component in components {
            let outputtable: LineOutputtable

            switch component {
            case "<<\(string(for: .commitTypeHyperlink))>>":
                outputtable = format(component: .commitTypeHyperlink)
            case "<<\(string(for: .contributorEmail))>>":
                outputtable = format(component: .contributorEmail)
            case "<<\(string(for: .contributorHandle))>>":
                outputtable = format(component: .contributorHandle)
            case "<<\(string(for: .message))>>":
                outputtable = format(component: .message)
            case "<<\(string(for: .tags))>>":
                outputtable = format(component: .tags)
            case "<<\(string(for: .sha))>>":
                outputtable = format(component: .sha)
            default:
                outputtable = component
            }

            transformedComp.append(outputtable)
        }

        return transformedComp
    }
}
