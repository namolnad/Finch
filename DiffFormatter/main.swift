//
//  main.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

let process = ProcessInfo.processInfo

let configurator = Configurator(processInfo: process)

let app = App()

let router = ArgumentRouter(app: app, configuration: configurator.configuration)

let args: [String] = process
    .arguments
    .filter { !$0.contains(app.name) }

if case .notHandled = router.route(arguments: args) {
    print("Unable to handle included arguments")
}
