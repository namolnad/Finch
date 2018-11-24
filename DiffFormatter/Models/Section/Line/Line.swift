//
//  Line.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Section.Line: Outputtable {
    var output: String {
        return value
    }
}

extension Section.Line {
    static func from(components: Section.Line.Components, context: Section.Line.Context) -> Section.Line {
        let value = context.sectionInfo.format.reduce("") { partial, next in
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
