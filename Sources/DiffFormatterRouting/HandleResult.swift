//
//  HandleResult.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public enum HandleResult {
    case handled
    case notHandled
    case partiallyHandled(unprocessedArgs: [Argument])
}

extension HandleResult: Equatable {}
