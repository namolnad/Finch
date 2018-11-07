//
//  main.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

let process = ProcessInfo.processInfo

let app = App()

var args: [String] = process
    .arguments
    .filter { !$0.contains(app.name) }

let scheme = ArgumentScheme(arguments: args)

let configurator = Configurator(processInfo: process, argScheme: scheme)

let router = ArgumentRouter(app: app, configuration: configurator.configuration)

if case .notHandled = router.route(argScheme: scheme) {
    print("Unable to handle included arguments")
}
