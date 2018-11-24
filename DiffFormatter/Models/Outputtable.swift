//
//  Outputtable.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

protocol Outputtable {
    var output: String { get }
}

extension Array: Outputtable where Element: Outputtable {
    var output: String {
        return map { $0.output }
            .joined(separator: "\n")
    }
}
