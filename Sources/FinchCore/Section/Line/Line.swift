//
//  Line.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct Line {
    let value: String
}

extension Line {
    static func from(components: LineComponents, context: LineContext) -> Line {
        let template: FormatTemplate = context.sectionInfo.formatTemplate ??
            context.configuration.sectionsConfig.formatTemplate ??
            .default

        let value = template.outputtables.reduce("") { partial, next in
            let nextOut = next.output(components: components, context: context)
            if partial.hasSuffix(" ") && nextOut.hasPrefix(" ") {
                return partial + String(nextOut.dropFirst())
            } else {
                return partial + nextOut
            }
        }

        return .init(value: value)
    }
}

extension Line: Outputtable {
    public var output: String {
        return value
    }
}
