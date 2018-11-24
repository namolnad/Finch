//
//  ArgumentScheme.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/6/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

struct ArgumentScheme {
    let oldVersion: String?
    let newVersion: String?
    let args: [Argument]
}

extension ArgumentScheme {
    init(arguments: [String]) {
        let versions = arguments.prefix(while: { !$0.hasPrefix("-") })

        self.init(
            oldVersion: versions.count == 2 ? versions.first : nil,
            newVersion: versions.count == 2 ? versions.last : nil,
            args: arguments.compactMap(Argument.init)
        )
    }
}
