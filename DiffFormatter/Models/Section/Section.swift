//
//  Section.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/15/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Section {
    struct Line {
        private let value: String

        init(value: String) {
            self.value = value
        }
    }

    let configuration: Configuration
    let info: Info
    let linesComponents: [LineComponents]
}

extension Section {
    func inserting(lineComponents: LineComponents) -> Section {
        return .init(
            configuration: configuration,
            info: info,
            linesComponents: linesComponents + [lineComponents]
        )
    }
}

extension Section {
    var lines: [Line] {
        return linesComponents
            .map { component in
                let value = info.format.reduce("") { partial, next in
                    let nextOut = next.output(components: component, configuration: configuration)
                    if partial.hasSuffix(" ") && nextOut.hasPrefix(" ") {
                        return partial + String(nextOut.dropFirst())
                    } else {
                        return partial + nextOut
                    }
                }

                return Line(value: value)
        }
    }
}

extension Section {
    static func `default`(for info: Section.Info, configuration: Configuration) -> Section {
        return Section(configuration: configuration, info: info, linesComponents: [])
    }
}

extension Section.Line: Outputtable {
    var output: String {
        return value
    }
}

extension Section: Outputtable {
    var output: String {
        return """

        ### \(info.title)
        \(lines.output)

        """
    }
}
