//
//  App.swift
//  DiffFormatterCore
//
//  Created by Dan Loman on 9/16/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public struct App {
    public let buildNumber: Int
    public let name: String
    public let version: Version

    public init(buildNumber: Int, name: String, version: Version) {
        self.buildNumber = buildNumber
        self.name = name
        self.version = version
    }
}
