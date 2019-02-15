//
//  FormatTemplate.swift
//  FinchCore
//
//  Created by Dan Loman on 1/2/19.
//  Copyright © 2019 DHL. All rights reserved.
//

public struct FormatTemplate {
    let outputtables: [LineOutputtable]
}

extension FormatTemplate {
    init?(formatString: String?) {
        guard let outputtables = formatString?.lineOutputtables, !outputtables.isEmpty else {
            return nil
        }

        self.init(outputtables: outputtables)
    }

    // Equivalent to: " - << tags >> << message >> — << commit_type_hyperlink >> — << contributor_handle >>"
    static let `default`: FormatTemplate = .init(
        outputtables: [
            " - ",
            FormatComponent.tags,
            " ",
            FormatComponent.message,
            " - ",
            FormatComponent.commitTypeHyperlink,
            " - ",
            FormatComponent.contributorHandle
        ]
    )

    var formatString: String {
        return outputtables.reduce("") { (partial: String, outputtable: LineOutputtable) in
            switch outputtable {
            case let component as FormatComponent:
                return partial + "<< \(component.rawValue) >>"
            case let string as String:
                return partial + string
            default:
                return partial
            }
        }
    }
}

private extension String {
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

        func string(for formatComponent: FormatComponent) -> String {
            return formatComponent.rawValue
        }

        func format(component: FormatComponent) -> LineOutputtable {
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

        var transformedComps: [LineOutputtable] = []

        for component in components {
            let outputtable: LineOutputtable

            switch component {
            case "<< \(string(for: .commitTypeHyperlink)) >>":
                outputtable = format(component: .commitTypeHyperlink)
            case "<< \(string(for: .contributorEmail)) >>":
                outputtable = format(component: .contributorEmail)
            case "<< \(string(for: .contributorHandle)) >>":
                outputtable = format(component: .contributorHandle)
            case "<< \(string(for: .message)) >>":
                outputtable = format(component: .message)
            case "<< \(string(for: .tags)) >>":
                outputtable = format(component: .tags)
            case "<< \(string(for: .sha)) >>":
                outputtable = format(component: .sha)
            default:
                outputtable = component
            }

            transformedComps.append(outputtable)
        }

        return transformedComps
    }
}
