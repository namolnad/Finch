//
//  main.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterApp
import DiffFormatterUtilities
import Foundation

let processInfo: ProcessInfo = .processInfo

let meta: App.Meta = .init(
    buildNumber: appBuildNumber,
    name: appName,
    version: appVersion
)

let runner = AppRunner(
    environment: processInfo.environment,
    meta: meta
)

do {
    try runner.run(arguments: processInfo.arguments)
} catch {
    Output.print("\(error)", kind: .error)
}
