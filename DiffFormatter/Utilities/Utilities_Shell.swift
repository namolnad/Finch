//
//  Utilities_Shell.swift
//  DiffFormatter
//
//  Created by Dan Loman on 8/17/18.
//  Copyright © 2018 DHL. All rights reserved.
//

import Foundation

extension Utilities {
    static func shell(executablePath: String, arguments: [String], currentDirectoryPath: String) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: executablePath)
        task.currentDirectoryURL = URL(fileURLWithPath: currentDirectoryPath)
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        try? task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}
