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

    init(value: String) {
        self.value = value
        self.tags = Set(
            matches(pattern: "\\|([^\\|]*)\\|", body: value).compactMap {
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
