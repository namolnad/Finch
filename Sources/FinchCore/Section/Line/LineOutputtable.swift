//
//  LineOutputtable.swift
//  Finch
//
//  Created by Dan Loman on 11/23/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

/// :nodoc:
protocol LineOutputtable {
    func output(components: LineComponents, context: LineContext) -> String
}
