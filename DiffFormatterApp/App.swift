//
//  App.swift
//  DiffFormatterApp
//
//  Created by Dan Loman on 1/13/19.
//  Copyright © 2019 DHL. All rights reserved.
//

import DiffFormatterCore
import DiffFormatterRouting
import DiffFormatterTelemetry

extension App {
    public func run(processInfo: ProcessInfo) {
        let args: [String] = Array(processInfo
            .arguments
            .dropFirst() // Remove app name/command
        )

        let scheme = ArgumentScheme(arguments: args)

        let configurator = Configurator(processInfo: processInfo, argScheme: scheme)

        let router = ArgumentRouter(
            app: self,
            configuration: configurator.configuration,
            handlers: [
                ArgumentRouter.usageHandler,
                ArgumentRouter.versionHandler,
                ArgumentRouter.diffHandler
            ]
        )

        if case .notHandled = router.route(argScheme: scheme) {
            log.error("Unable to handle included arguments")
        }
    }
}
