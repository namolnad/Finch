//
//  String+DiffFormatterUtilities.swift
//  DiffFormatterUtilities
//
//  Created by Dan Loman on 1/7/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import Foundation

extension String {
    public var escaped: String {
        return NSRegularExpression.escapedPattern(for: self)
    }
}
