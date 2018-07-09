//
//  Command.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

typealias CommandValue = (command: Command, value: String)

enum Command: String {
    case version
    case releaseManager = "manager"
}
