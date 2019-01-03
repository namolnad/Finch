//
//  ArgumentScheme.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/6/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

typealias Versions = (old: String, new: String)

enum ArgumentScheme {
    case diffable(versions: Versions, args: [Argument])
    case nonDiffable(args: [Argument])

    var args: [Argument] {
        switch self {
        case .diffable(_, let args), .nonDiffable(let args):
            return args
        }
    }
}

extension ArgumentScheme {
    init(arguments: [String]) {
        guard case let versions = arguments.prefix(while: { !$0.hasPrefix("-") }),
            versions.count == 2,
            let old = versions.first,
            let new = versions.last else {
                self = .nonDiffable(args: arguments.compactMap(Argument.init))
                return
        }

        self = .diffable(
            versions: (old: old, new: new),
            args: arguments.compactMap(Argument.init)
        )
    }
}
