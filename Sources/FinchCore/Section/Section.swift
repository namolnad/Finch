//
//  Section.swift
//  FinchCore
//
//  Created by Dan Loman on 1/7/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

public struct Section {
    public let configuration: Configuration
    public let info: SectionInfo
    public let linesComponents: [LineComponents]

    public init(configuration: Configuration, info: SectionInfo, linesComponents: [LineComponents]) {
        self.configuration = configuration
        self.info = info
        self.linesComponents = linesComponents
    }
}

extension Section {
    var lines: [Line] {
        return linesComponents.map { components -> Line in
            .from(
                components: components,
                context: .init(
                    configuration: configuration,
                    sectionInfo: info
                )
            )
        }
    }

    public func inserting(lineComponents: LineComponents) -> Section {
        return .init(
            configuration: configuration,
            info: info,
            linesComponents: linesComponents + [lineComponents]
        )
    }
}

extension Section: Outputtable {
    public var output: String {
        return """

        ### \(info.title)
        \(lines.output)

        """
    }
}
