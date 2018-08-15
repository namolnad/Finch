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

let router = ArgumentRouter(configuration: configurator.configuration)

router.route(arguments: process.arguments)


