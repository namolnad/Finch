//
//  Utilities.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public var isTest: Bool {
    return NSClassFromString("XCTestCase") != nil
}
