//
//  main.swift
//  DiffFormatter
//
//  Created by Dan Loman on 7/5/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import DiffFormatterApp
import DiffFormatterCore
import Foundation

App(
    buildNumber: appBuildNumber,
    name: appName,
    version: appVersion
).run(processInfo: ProcessInfo.processInfo)
