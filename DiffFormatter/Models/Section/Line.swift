//
//  Line.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/15/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct Line {
    let tags: Set<String>
    let value: String

    init(configuration: Configuration, value: String) {
        self.value = value
        let outputDelimiters = configuration.delimiterConfig.output
        self.tags = Set(
            matches(pattern: "\(outputDelimiters.left.escaped)([^\(outputDelimiters.left.escaped)\(outputDelimiters.right.escaped)]*)\(outputDelimiters.right.escaped)", body: value).compactMap {
                guard $0.numberOfRanges > 0 else {
                    return nil
                }
                return String(range: $0.range(at: 1), in: value)
            }
        )
    }
}

extension Line {
    func belongsTo(sectionInfo: SectionInfo) -> Bool {
        return sectionInfo.tags.contains("*") ||
            !sectionInfo.tags.isDisjoint(with: tags)
    }
}
