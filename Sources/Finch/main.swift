//
//  main.swift
//  Finch
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchApp
import Foundation

let processInfo: ProcessInfo = .processInfo

let meta: App.Meta = .init(
    buildNumber: appBuildNumber,
    name: appName,
    version: appVersion
)

AppRunner(
    environment: processInfo.environment,
    meta: meta
).run(arguments: processInfo.arguments)
