//
//  main.swift
//  Finch
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchApp
import Foundation

let meta: App.Meta = .init(
    buildNumber: appBuildNumber,
    name: appName,
    version: appVersion
)

let result = AppRunner(
    environment: ProcessInfo.processInfo.environment,
    meta: meta
).run(with: CommandLine.arguments)

exit(result)
