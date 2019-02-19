//
//  Outputtable.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

/// :nodoc:
public protocol Outputtable {
    var output: String { get }
}

/// :nodoc:
extension Array: Outputtable where Element: Outputtable {
    public var output: String {
        return map { $0.output }
            .joined(separator: "\n")
    }
}
