//
//  RoutingContext.swift
//  DiffFormatter
//
//  Created by Dan Loman on 11/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterCore

public struct RoutingContext {
    public let app: App
    public let configuration: Configuration
    public let output: (String) -> Void
}
