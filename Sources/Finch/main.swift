//
//  main.swift
//  Finch
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import FinchApp
import FinchUtilities
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
    let formattedError: String = .localizedStringWithFormat(
        NSLocalizedString(
            "Error: %@",
            comment: "Formatted error message"
        ),
        error.localizedDescription
    )

    Output.instance.print(formattedError, kind: .error)
}
