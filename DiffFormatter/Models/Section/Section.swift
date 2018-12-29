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
        let value: String
    }

    let configuration: Configuration
    let info: Info
    let linesComponents: [Line.Components]
}

extension Section {
    var lines: [Line] {
        return linesComponents.map { components -> Section.Line in
            .from(
                components: components,
                context: .init(
                    configuration: configuration,
                    sectionInfo: info
                )
            )
        }
    }

    func inserting(lineComponents: Line.Components) -> Section {
        return .init(
            configuration: configuration,
            info: info,
            linesComponents: linesComponents + [lineComponents]
        )
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
