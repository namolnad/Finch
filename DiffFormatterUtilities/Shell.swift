//
//  Shell.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

public func shell(
    executablePath: String,
    arguments: [String],
    currentDirectoryPath: String,
    environment: [String: String]? = nil) -> String? {
    let task = Process()

    if #available(OSX 10.13, *) {
        task.executableURL = URL(fileURLWithPath: executablePath)
        task.currentDirectoryURL = URL(fileURLWithPath: currentDirectoryPath)
    } else {
        task.launchPath = executablePath
        task.currentDirectoryPath = currentDirectoryPath
    }

    task.arguments = arguments

    if let environment = environment, case let env = task.environment ?? [:] {
        task.environment = env.merging(environment) { $1 }
    }

    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe

    if #available(OSX 10.13, *) {
        try? task.run()
    } else {
        task.launch()
    }

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)
}
