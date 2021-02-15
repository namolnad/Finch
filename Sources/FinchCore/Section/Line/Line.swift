//
//  Line.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

/// :nodoc:
public struct Line {
    let value: String
}

/// :nodoc:
extension Line {
    static func from(components: LineComponents, context: LineContext) -> Line {
        let template: FormatTemplate = context.sectionInfo.formatTemplate ??
            context.configuration.formatConfig.formatTemplate ??
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

/// :nodoc:
extension Line: Outputtable {
    public var output: String {
        value
    }
}
